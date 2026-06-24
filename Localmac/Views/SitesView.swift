import SwiftUI

struct SitesView: View {
    @StateObject private var viewModel = SiteViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Sites")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button(action: { viewModel.showAddSite = true }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            if viewModel.sites.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "globe.slash")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No sites yet")
                        .foregroundColor(.secondary)
                    Button("Add your first site") {
                        viewModel.showAddSite = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.sites) { site in
                    SiteRowView(site: site)
                }
                .listStyle(.plain)
            }
        }
        .sheet(isPresented: $viewModel.showAddSite) {
            AddSiteView(viewModel: viewModel)
        }
    }
}

struct SiteRowView: View {
    let site: Site

    var body: some View {
        HStack {
            Circle()
                .fill(site.isActive ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(site.domain)
                    .font(.system(size: 12, weight: .medium))
                Text("PHP \(site.phpVersion) · \(site.type.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: { openInBrowser(site) }) {
                Image(systemName: "safari")
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
        }
        .padding(.vertical, 4)
    }

    private func openInBrowser(_ site: Site) {
        if let url = URL(string: "https://\(site.domain)") {
            NSWorkspace.shared.open(url)
        }
    }
}

struct AddSiteView: View {
    @ObservedObject var viewModel: SiteViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phpVersion = "8.3"
    @State private var siteType = SiteType.wordpress

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add New Site")
                .font(.headline)

            TextField("Site name (e.g. myproject)", text: $name)
                .textFieldStyle(.roundedBorder)

            Picker("Type", selection: $siteType) {
                ForEach(SiteType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }

            Picker("PHP Version", selection: $phpVersion) {
                ForEach(["7.4","8.1","8.2","8.3","8.4","8.5","8.6"], id: \.self) {
                    Text("PHP \($0)").tag($0)
                }
            }

            if siteType == .wordpress {
                Label("WordPress will be downloaded and configured automatically.", systemImage: "info.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Create Site") {
                    viewModel.addSite(name: name, type: siteType, phpVersion: phpVersion)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 320)
    }
}
