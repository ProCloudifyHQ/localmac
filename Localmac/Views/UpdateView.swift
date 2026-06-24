import SwiftUI

struct UpdateBannerView: View {
    @ObservedObject var updateChecker: UpdateChecker

    var body: some View {
        if updateChecker.updateAvailable, let release = updateChecker.latestRelease {
            HStack(spacing: 10) {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Update available — v\(release.version)")
                        .font(.system(size: 12, weight: .semibold))
                    Text("You have v\(updateChecker.currentVersionString)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button("View") {
                    updateChecker.showUpdateSheet = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding(10)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal, 12)
            .sheet(isPresented: $updateChecker.showUpdateSheet) {
                UpdateSheetView(updateChecker: updateChecker)
            }
        }
    }
}

struct UpdateSheetView: View {
    @ObservedObject var updateChecker: UpdateChecker
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Header
            HStack {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Localmac \(updateChecker.latestRelease.map { "v\($0.version)" } ?? "")")
                        .font(.title2.weight(.bold))
                    Text("Current: v\(updateChecker.currentVersionString)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }

            Divider()

            // Changelog
            if let notes = updateChecker.latestRelease?.body, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's New")
                        .font(.headline)
                    ScrollView {
                        Text(notes)
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 200)
                    .padding(10)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                }
            }

            Divider()

            // Install options
            VStack(alignment: .leading, spacing: 8) {
                Text("Install Update")
                    .font(.headline)

                HStack(spacing: 12) {
                    Button {
                        updateChecker.openReleasePage()
                        dismiss()
                    } label: {
                        Label("Download .dmg", systemImage: "arrow.down.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        copyBrewCommand()
                        dismiss()
                    } label: {
                        Label("Copy brew command", systemImage: "doc.on.clipboard")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                Text("brew upgrade --cask localmac")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(24)
        .frame(width: 440)
    }

    private func copyBrewCommand() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("brew upgrade --cask localmac", forType: .string)
    }
}

struct UpdateSettingsView: View {
    @StateObject private var updateChecker = UpdateChecker()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Updates")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
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

            if updateChecker.updateAvailable {
                UpdateSheetView(updateChecker: updateChecker)
                    .background(Color.green.opacity(0.05))
                    .cornerRadius(10)
            } else if !updateChecker.isChecking {
                Label("Localmac is up to date", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.subheadline)
            }
        }
        .padding()
        .onAppear { Task { await updateChecker.checkForUpdates() } }
        .sheet(isPresented: $updateChecker.showUpdateSheet) {
            UpdateSheetView(updateChecker: updateChecker)
        }
    }
}
