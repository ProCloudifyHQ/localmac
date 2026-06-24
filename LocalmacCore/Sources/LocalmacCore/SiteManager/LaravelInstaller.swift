import Foundation

public actor LaravelInstaller {
    public static let shared = LaravelInstaller()

    public func install(at path: String, domain: String) async throws {
        // Requires composer globally
        let composer = await Shell.run("which composer").output
        guard !composer.isEmpty else {
            throw LocalmacError.laravelInstallFailed("Composer not found. Install via: brew install composer")
        }

        let parent = (path as NSString).deletingLastPathComponent
        let name   = (path as NSString).lastPathComponent

        let result = await Shell.run("cd '\(parent)' && composer create-project laravel/laravel '\(name)' --prefer-dist")
        if !result.succeeded { throw LocalmacError.laravelInstallFailed(result.error) }

        // Update .env
        let envPath = "\(path)/.env"
        if var env = try? String(contentsOfFile: envPath, encoding: .utf8) {
            env = env.replacingOccurrences(of: "APP_URL=http://localhost", with: "APP_URL=https://\(domain)")
            try? env.write(toFile: envPath, atomically: true, encoding: .utf8)
        }

        // Generate key
        await Shell.run("cd '\(path)' && php artisan key:generate")
    }
}
