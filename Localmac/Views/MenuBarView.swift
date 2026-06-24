import SwiftUI

struct MenuBarView: View {
    @StateObject private var updateChecker = UpdateChecker()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "server.rack")
                    .foregroundColor(.accentColor)
                Text("Localmac")
                    .font(.headline)
                Spacer()
                Text("v\(updateChecker.currentVersionString)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            // Update banner
            UpdateBannerView(updateChecker: updateChecker)
                .padding(.top, updateChecker.updateAvailable ? 8 : 0)

            // Main content tabs
            TabView {
                SitesView()
                    .tabItem { Label("Sites", systemImage: "globe") }

                ServicesView()
                    .tabItem { Label("Services", systemImage: "gearshape.2") }

                DashboardView()
                    .tabItem { Label("Dashboard", systemImage: "chart.bar") }
            }
            .padding(.horizontal, 8)

            Divider()

            // Footer actions
            HStack {
                Button("Settings") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
                .buttonStyle(.plain)
                .font(.caption)

                Spacer()

                Button("Quit Localmac") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundColor(.red)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}
