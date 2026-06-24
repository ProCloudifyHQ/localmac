import Foundation

enum SiteType: String, CaseIterable, Codable {
    case wordpress = "WordPress"
    case laravel   = "Laravel"
    case php       = "PHP"
    case other     = "Other"
}

struct Site: Identifiable, Codable {
    let id: UUID
    var name: String
    var domain: String        // e.g. myproject.test
    var phpVersion: String
    var type: SiteType
    var isActive: Bool
    var rootPath: String      // absolute path to site root
    var databaseName: String?
    var createdAt: Date

    init(name: String, phpVersion: String, type: SiteType, sitesDirectory: String) {
        self.id = UUID()
        self.name = name
        self.domain = "\(name.lowercased().replacingOccurrences(of: " ", with: "-")).test"
        self.phpVersion = phpVersion
        self.type = type
        self.isActive = false
        self.rootPath = "\(sitesDirectory)/\(name)"
        self.databaseName = name.lowercased().replacingOccurrences(of: "-", with: "_")
        self.createdAt = Date()
    }
}
