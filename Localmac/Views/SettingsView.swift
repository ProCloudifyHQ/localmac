import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }

            UpdateSettingsView()
                .tabItem { Label("Updates", systemImage: "arrow.down.circle") }

            PHPSettingsView()
                .tabItem { Label("PHP", systemImage: "chevron.left.forwardslash.chevron.right") }
        }
        .frame(width: 480, height: 320)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = true
    @AppStorage("sitesDirectory") private var sitesDirectory = "~/Sites"

    var body: some View {
        Form {
            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { LaunchAtLoginManager.set($0) }

            LabeledContent("Sites directory") {
                HStack {
                    Text(sitesDirectory)
                        .foregroundColor(.secondary)
                    Button("Change") { chooseSitesDirectory() }
                }
            }
        }
        .padding()
    }

    private func chooseSitesDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            sitesDirectory = url.path
        }
    }
}

struct PHPSettingsView: View {
    let phpVersions = ["7.4","8.1","8.2","8.3","8.4","8.5","8.6"]
    @AppStorage("defaultPHP") private var defaultPHP = "8.3"

    var body: some View {
        Form {
            Picker("Default PHP version", selection: $defaultPHP) {
                ForEach(phpVersions, id: \.self) { Text("PHP \($0)").tag($0) }
            }
            Text("ionCube Loader is included for all PHP versions.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
