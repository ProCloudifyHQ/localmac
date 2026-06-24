import Foundation
import AppKit

struct GitHubRelease: Decodable {
    let tagName: String
    let htmlUrl: String
    let body: String
    let assets: [Asset]

    struct Asset: Decodable {
        let name: String
        let browserDownloadUrl: String
    }

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlUrl = "html_url"
        case body
        case assets
    }

    var version: String {
        tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
    }

    var dmgAsset: Asset? {
        assets.first { $0.name.hasSuffix(".dmg") }
    }
}

@MainActor
final class UpdateChecker: ObservableObject {
    @Published var latestRelease: GitHubRelease?
    @Published var isChecking = false
    @Published var updateAvailable = false

    private let apiURL = URL(string: "https://api.github.com/repos/ProCloudifyHQ/localmac/releases/latest")!
    private let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"

    func checkForUpdatesOnLaunch() {
        // Only auto-check once per day
        let lastCheck = UserDefaults.standard.double(forKey: "lastUpdateCheck")
        let oneDayAgo = Date().timeIntervalSince1970 - 86400
        guard lastCheck < oneDayAgo else { return }
        Task { await checkForUpdates() }
    }

    func checkForUpdates() async {
        isChecking = true
        defer { isChecking = false }

        do {
            var request = URLRequest(url: apiURL)
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            let (data, _) = try await URLSession.shared.data(for: request)
            let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
            latestRelease = release
            updateAvailable = isNewerVersion(release.version, than: currentVersion)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastUpdateCheck")
        } catch {
            // Silent fail — update check is non-critical
        }
    }

    func openReleasePage() {
        guard let urlString = latestRelease?.htmlUrl,
              let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }

    private func isNewerVersion(_ remote: String, than local: String) -> Bool {
        remote.compare(local, options: .numeric) == .orderedDescending
    }

    var currentVersionString: String { currentVersion }
}
