import Foundation

public enum PHPVersion: String, CaseIterable, Codable {
    case php74 = "7.4"
    case php81 = "8.1"
    case php82 = "8.2"
    case php83 = "8.3"
    case php84 = "8.4"
    case php85 = "8.5"
    case php86 = "8.6"

    public var brewFormula: String {
        rawValue == "8.6" ? "php" : "php@\(rawValue)"
    }

    public var fpmServiceName: String { brewFormula }

    public var installPath: String {
        "/opt/homebrew/opt/\(brewFormula)"
    }

    public var fpmSockPath: String {
        "/opt/homebrew/var/run/php/php\(rawValue)-fpm.sock"
    }

    public var iniPath: String {
        "/opt/homebrew/etc/php/\(rawValue)/php.ini"
    }
}

public actor PHPManager {
    public static let shared = PHPManager()

    private let ioncubeBaseURL = "https://downloads.ioncube.com/loader_downloads"

    public func installedVersions() async -> [PHPVersion] {
        var installed: [PHPVersion] = []
        for version in PHPVersion.allCases {
            let result = await Shell.run("test -d \(version.installPath) && echo yes")
            if result.output == "yes" { installed.append(version) }
        }
        return installed
    }

    public func install(_ version: PHPVersion) async throws {
        // Add shivammathur tap for all PHP versions
        _ = await Shell.brew("tap shivammathur/php")
        let result = await Shell.brew("install shivammathur/php/\(version.brewFormula)")
        if !result.succeeded {
            throw LocalmacError.installFailed(version.brewFormula, result.error)
        }
        try await configurePhpIni(version)
        try await installIoncube(version)
    }

    public func switchGlobal(to version: PHPVersion) async throws {
        // Unlink all, link target
        for v in PHPVersion.allCases {
            _ = await Shell.brew("unlink \(v.brewFormula)")
        }
        let result = await Shell.brew("link --overwrite --force \(version.brewFormula)")
        if !result.succeeded {
            throw LocalmacError.phpSwitchFailed(version.rawValue, result.error)
        }
    }

    public func startFPM(_ version: PHPVersion) async throws {
        let result = await Shell.brew("services start \(version.fpmServiceName)")
        if !result.succeeded {
            throw LocalmacError.serviceStartFailed(version.fpmServiceName, result.error)
        }
    }

    public func stopFPM(_ version: PHPVersion) async throws {
        _ = await Shell.brew("services stop \(version.fpmServiceName)")
    }

    public func stopAllFPM() async {
        for version in PHPVersion.allCases {
            _ = await Shell.brew("services stop \(version.fpmServiceName)")
        }
    }

    // MARK: - php.ini configuration

    private func configurePhpIni(_ version: PHPVersion) async throws {
        let iniPath = version.iniPath
        guard FileManager.default.fileExists(atPath: iniPath) else { return }

        let settings: [(String, String)] = [
            ("upload_max_filesize", "2048M"),
            ("post_max_size",       "2048M"),
            ("memory_limit",        "512M"),
            ("max_execution_time",  "300"),
            ("max_input_time",      "300"),
            ("date.timezone",       "UTC"),
        ]

        var ini = (try? String(contentsOfFile: iniPath, encoding: .utf8)) ?? ""
        for (key, value) in settings {
            let pattern = "^\(key)\\s*=.*"
            let replacement = "\(key) = \(value)"
            if ini.range(of: pattern, options: .regularExpression) != nil {
                ini = ini.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
            } else {
                ini += "\n\(replacement)"
            }
        }
        try ini.write(toFile: iniPath, atomically: true, encoding: .utf8)
    }

    // MARK: - ionCube Loader

    public func installIoncube(_ version: PHPVersion) async throws {
        let arch = await Shell.run("uname -m").output
        let archStr = arch.contains("arm") ? "aarch64" : "x86-64"
        let tarName = "ioncube_loaders_mac_\(archStr).tar.gz"
        let downloadURL = "\(ioncubeBaseURL)/\(tarName)"
        let tmpDir = FileManager.default.temporaryDirectory.path

        // Download
        var result = await Shell.run("curl -fsSL '\(downloadURL)' -o '\(tmpDir)/\(tarName)'")
        if !result.succeeded { throw LocalmacError.ioncubeDownloadFailed(result.error) }

        // Extract
        result = await Shell.run("tar -xzf '\(tmpDir)/\(tarName)' -C '\(tmpDir)'")
        if !result.succeeded { throw LocalmacError.ioncubeDownloadFailed(result.error) }

        // Find the right .so
        let soName = "ioncube_loader_mac_\(version.rawValue).so"
        let soPath = "\(tmpDir)/ioncube/\(soName)"

        guard FileManager.default.fileExists(atPath: soPath) else {
            throw LocalmacError.ioncubeDownloadFailed("Loader not found for PHP \(version.rawValue)")
        }

        // Get extension dir
        let extDir = await Shell.run("/opt/homebrew/opt/\(version.brewFormula)/bin/php -r 'echo ini_get(\"extension_dir\");'").output
        guard !extDir.isEmpty else { throw LocalmacError.ioncubeDownloadFailed("Cannot find extension dir") }

        // Copy loader
        result = await Shell.run("cp '\(soPath)' '\(extDir)/\(soName)'")
        if !result.succeeded { throw LocalmacError.ioncubeDownloadFailed(result.error) }

        // Add zend_extension to php.ini (must be first extension)
        let iniPath = version.iniPath
        var ini = (try? String(contentsOfFile: iniPath, encoding: .utf8)) ?? ""
        let zendLine = "zend_extension=\(extDir)/\(soName)"
        if !ini.contains("ioncube") {
            ini = zendLine + "\n" + ini
            try ini.write(toFile: iniPath, atomically: true, encoding: .utf8)
        }
    }
}
