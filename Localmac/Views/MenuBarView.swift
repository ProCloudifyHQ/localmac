import SwiftUI

struct MenuBarView: View {
    @StateObject private var updateChecker = UpdateChecker()
    @State private var selectedTab = 0

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
            .padding(.top, 14)
            .padding(.bottom, 10)

            // Update banner
            if updateChecker.updateAvailable {
                UpdateBannerView(updateChecker: updateChecker)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
            }

            Divider()

            // Tab bar
            HStack(spacing: 0) {
                TabButton(title: "Sites",     icon: "globe",         index: 0, selected: $selectedTab)
                TabButton(title: "Services",  icon: "gearshape.2",   index: 1, selected: $selectedTab)
                TabButton(title: "Dashboard", icon: "chart.bar",     index: 2, selected: $selectedTab)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            Divider()

            // Content
            Group {
                switch selectedTab {
                case 0: SitesView()
                case 1: ServicesView()
                case 2: DashboardView()
                default: SitesView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            // Footer
            HStack {
                Button("Settings") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    NSApp.activate(ignoringOtherApps: true)
                }
                .buttonStyle(.plain)
                .font(.caption)

                Spacer()

                Button("Quit") { NSApp.terminate(nil) }
                    .buttonStyle(.plain)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(width: 380)
        .sheet(isPresented: $updateChecker.showUpdateSheet) {
            UpdateSheetView(updateChecker: updateChecker)
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let index: Int
    @Binding var selected: Int

    var body: some View {
        Button {
            selected = index
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                Text(title)
                    .font(.system(size: 10))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(selected == index ? Color.accentColor.opacity(0.12) : Color.clear)
            .cornerRadius(6)
            .foregroundColor(selected == index ? .accentColor : .secondary)
        }
        .buttonStyle(.plain)
    }
}
