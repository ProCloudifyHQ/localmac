import Foundation

public actor DNSManager {
    public static let shared = DNSManager()

    private let dnsmasqConf = "/opt/homebrew/etc/dnsmasq.conf"
    private let resolverDir = "/etc/resolver"
    private let resolverFile = "/etc/resolver/test"

    public func setup() async throws {
        // Ensure dnsmasq routes all *.test to 127.0.0.1
        var conf = (try? String(contentsOfFile: dnsmasqConf, encoding: .utf8)) ?? ""
        let rule = "address=/.test/127.0.0.1"
        if !conf.contains(rule) {
            conf += "\n\(rule)\n"
            try conf.write(toFile: dnsmasqConf, atomically: true, encoding: .utf8)
        }

        // Create /etc/resolver/test (requires sudo — handled by XPC helper)
        let resolverContent = "nameserver 127.0.0.1\n"
        try await writePrivileged(resolverContent, to: resolverFile)

        _ = await Shell.brew("services restart dnsmasq")
    }

    public func addDomain(_ domain: String) async throws {
        // dnsmasq wildcard already covers *.test — no per-domain entry needed
        // Just ensure dnsmasq is running
        let result = await Shell.brew("services list")
        if result.output.contains("dnsmasq started") { return }
        try await setup()
    }

    public func removeDomain(_ domain: String) async throws {
        // No-op: wildcard covers everything, no per-domain cleanup needed
    }

    // Writes a file that requires root — bridges to XPC helper in production
    private func writePrivileged(_ content: String, to path: String) async throws {
        // In development (no XPC helper yet): use osascript for sudo
        let escaped = content.replacingOccurrences(of: "'", with: "'\\''")
        await Shell.run("echo '\(escaped)' | sudo tee '\(path)' > /dev/null")
    }
}
