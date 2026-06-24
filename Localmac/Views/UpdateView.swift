import SwiftUI

struct UpdateBannerView: View {
    @ObservedObject var updateChecker: UpdateChecker

    var body: some View {
        if updateChecker.updateAvailable, let release = updateChecker.latestRelease {
            HStack(spacing(10)) {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Update available: v\(release.version)")
                        .font(.system(size: 12, weight: .semibold))
                    Text("You have v\(updateChecker.currentVersionString)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button("Update") {
                    updateChecker.openReleasePage()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding(10)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal, 12)
        }
    }
}

struct UpdateSettingsView: View {
    @StateObject private var updateChecker = UpdateChecker()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Updates")
                .font(.headline)

            HStack {
                VStack(alignment: .leading) {
                    Text("Current version")
                        .font(.subheadline)
                    Text("v\(updateChecker.currentVersionString)")
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(updateChecker.isChecking ? "Checking..." : "Check for Updates") {
                    Task { await updateChecker.checkForUpdates() }
                }
                .disabled(updateChecker.isChecking)
            }

            if updateChecker.updateAvailable, let release = updateChecker.latestRelease {
                VStack(alignment: .leading, spacing: 8) {
                    Label("v\(release.version) is available", systemImage: "arrow.down.circle.fill")
                        .foregroundColor(.green)
                        .font(.subheadline)

                    if !release.body.isEmpty {
                        Text(release.body)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(6)
                    }

                    HStack {
                        Button("Download .dmg") {
                            updateChecker.openReleasePage()
                        }
                        .buttonStyle(.borderedProminent)

                        Text("or run: brew upgrade --cask localmac")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.08))
                .cornerRadius(8)
            } else if !updateChecker.isChecking {
                Label("Localmac is up to date", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
        .padding()
        .onAppear {
            Task { await updateChecker.checkForUpdates() }
        }
    }
}
