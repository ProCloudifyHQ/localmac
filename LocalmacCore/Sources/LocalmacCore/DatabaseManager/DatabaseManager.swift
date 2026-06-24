import Foundation

public actor DatabaseManager {
    public static let shared = DatabaseManager()

    private let mysql = "/opt/homebrew/bin/mysql"

    public func createDatabase(_ name: String) async throws {
        let safeName = sanitize(name)
        let result = await Shell.run("\(mysql) -u root -e \"CREATE DATABASE IF NOT EXISTS \\`\(safeName)\\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\"")
        if !result.succeeded {
            throw LocalmacError.databaseFailed("Create failed for \(safeName): \(result.error)")
        }
    }

    public func dropDatabase(_ name: String) async throws {
        let safeName = sanitize(name)
        let result = await Shell.run("\(mysql) -u root -e \"DROP DATABASE IF EXISTS \\`\(safeName)\\`;\"")
        if !result.succeeded {
            throw LocalmacError.databaseFailed("Drop failed for \(safeName): \(result.error)")
        }
    }

    public func listDatabases() async throws -> [String] {
        let result = await Shell.run("\(mysql) -u root -e \"SHOW DATABASES;\" --batch --skip-column-names")
        if !result.succeeded { throw LocalmacError.databaseFailed(result.error) }
        return result.output
            .components(separatedBy: .newlines)
            .filter { !["information_schema","performance_schema","mysql","sys"].contains($0) && !$0.isEmpty }
    }

    public func exportDatabase(_ name: String, to path: String) async throws {
        let safeName = sanitize(name)
        let result = await Shell.run("/opt/homebrew/bin/mysqldump -u root \(safeName) > '\(path)'")
        if !result.succeeded { throw LocalmacError.databaseFailed(result.error) }
    }

    private func sanitize(_ name: String) -> String {
        name.components(separatedBy: CharacterSet.alphanumerics.union(.init(charactersIn: "_")).inverted).joined()
    }
}
