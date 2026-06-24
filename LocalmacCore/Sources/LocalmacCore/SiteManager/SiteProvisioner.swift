import Foundation

public actor SiteProvisioner {
    public static let shared = SiteProvisioner()

    private let nginxSitesDir = "/opt/homebrew/etc/nginx/servers"
    private let sitesRoot: String = {
        let path = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Sites").path
        try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        return path
    }()

    public func provision(name: String, type: SiteType, phpVersion: PHPVersion) async throws {
        let domain   = "\(name.lowercased().replacingOccurrences(of: " ", with: "-")).test"
        let rootPath = "\(sitesRoot)/\(name)"

        // 1. Create site directory
        try FileManager.default.createDirectory(atPath: rootPath, withIntermediateDirectories: true)

        // 2. SSL cert
        let (certPath, keyPath) = try await SSLManager.shared.generateCert(for: domain)

        // 3. Nginx config
        let siteConfig = SiteConfig(
            domain: domain,
            rootPath: rootPath,
            phpVersion: phpVersion,
            sslCertPath: certPath,
            sslKeyPath: keyPath
        )
        let nginxConf = NginxConfigGenerator.config(for: siteConfig)
        let confPath = "\(nginxSitesDir)/\(domain).conf"
        try nginxConf.write(toFile: confPath, atomically: true, encoding: .utf8)

        // 4. DNS entry (dnsmasq)
        try await DNSManager.shared.addDomain(domain)

        // 5. PHP-FPM for the version
        try await PHPManager.shared.startFPM(phpVersion)

        // 6. Type-specific setup
        switch type {
        case .wordpress: try await WordPressInstaller.shared.install(at: rootPath, domain: domain, dbName: name.lowercased())
        case .laravel:   try await LaravelInstaller.shared.install(at: rootPath, domain: domain)
        case .php:       try await createDefaultIndex(at: rootPath, domain: domain, php: phpVersion)
        case .other:     break
        }

        // 7. Reload Nginx
        _ = await Shell.brew("services reload nginx")
    }

    public func remove(domain: String, name: String) async throws {
        // Remove nginx config
        try? FileManager.default.removeItem(atPath: "\(nginxSitesDir)/\(domain).conf")
        // Remove SSL cert
        await SSLManager.shared.revokeCert(for: domain)
        // Remove DNS
        try? await DNSManager.shared.removeDomain(domain)
        // Reload
        _ = await Shell.brew("services reload nginx")
    }

    private func createDefaultIndex(at path: String, domain: String, php: PHPVersion) async throws {
        let html = """
        <?php
        phpinfo();
        """
        try html.write(toFile: "\(path)/index.php", atomically: true, encoding: .utf8)
    }
}

public enum SiteType: String, CaseIterable, Codable {
    case wordpress = "WordPress"
    case laravel   = "Laravel"
    case php       = "PHP"
    case other     = "Other"
}
