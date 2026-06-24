import Foundation

@MainActor
final class SiteViewModel: ObservableObject {
    @Published var sites: [Site] = []
    @Published var showAddSite = false

    private let savePath = FileManager.default
        .homeDirectoryForCurrentUser
        .appendingPathComponent(".localmac/sites.json")

    init() { load() }

    func addSite(name: String, type: SiteType, phpVersion: String) {
        let sitesDir = UserDefaults.standard.string(forKey: "sitesDirectory") ?? "~/Sites"
        var site = Site(name: name, phpVersion: phpVersion, type: type, sitesDirectory: sitesDir)
        site.isActive = true
        sites.append(site)
        save()
        Task { await provision(site) }
    }

    private func provision(_ site: Site) async {
        // Calls SiteProvisioner in LocalmacCore — wired up in Phase 2
    }

    private func save() {
        try? FileManager.default.createDirectory(at: savePath.deletingLastPathComponent(),
                                                  withIntermediateDirectories: true)
        if let data = try? JSONEncoder().encode(sites) {
            try? data.write(to: savePath)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: savePath),
              let decoded = try? JSONDecoder().decode([Site].self, from: data) else { return }
        sites = decoded
    }
}
