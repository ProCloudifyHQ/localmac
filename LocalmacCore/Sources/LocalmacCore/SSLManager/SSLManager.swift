import Foundation

public actor SSLManager {
    public static let shared = SSLManager()

    private let mkcert = "/opt/homebrew/bin/mkcert"
    private let certDir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".localmac/certs").path

    public func ensureInstalled() async throws {
        if !FileManager.default.fileExists(atPath: mkcert) {
            let result = await Shell.brew("install mkcert nss")
            if !result.succeeded { throw LocalmacError.installFailed("mkcert", result.error) }
        }
        // Install local CA if not already done
        let result = await Shell.run("\(mkcert) -install")
        if !result.succeeded { throw LocalmacError.sslFailed("CA install failed: \(result.error)") }
    }

    public func generateCert(for domain: String) async throws -> (cert: String, key: String) {
        try FileManager.default.createDirectory(atPath: certDir, withIntermediateDirectories: true)

        let certPath = "\(certDir)/\(domain).pem"
        let keyPath  = "\(certDir)/\(domain)-key.pem"

        // Skip if already exists
        if FileManager.default.fileExists(atPath: certPath) {
            return (certPath, keyPath)
        }

        let result = await Shell.run(
            "cd '\(certDir)' && \(mkcert) -cert-file '\(certPath)' -key-file '\(keyPath)' '\(domain)' '*.\(domain)'"
        )
        if !result.succeeded {
            throw LocalmacError.sslFailed("Failed to generate cert for \(domain): \(result.error)")
        }
        return (certPath, keyPath)
    }

    public func revokeCert(for domain: String) async {
        let certPath = "\(certDir)/\(domain).pem"
        let keyPath  = "\(certDir)/\(domain)-key.pem"
        try? FileManager.default.removeItem(atPath: certPath)
        try? FileManager.default.removeItem(atPath: keyPath)
    }
}
