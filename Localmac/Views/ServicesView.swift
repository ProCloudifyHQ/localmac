import SwiftUI

struct ServicesView: View {
    @StateObject private var viewModel = ServicesViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Services")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            List(viewModel.services) { service in
                ServiceRowView(service: service) {
                    viewModel.toggle(service)
                }
            }
            .listStyle(.plain)
        }
        .onAppear { viewModel.refreshStatus() }
    }
}

struct ServiceRowView: View {
    let service: Service
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Image(systemName: service.icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(service.name)
                    .font(.system(size: 12, weight: .medium))
                Text(service.status.label)
                    .font(.caption)
                    .foregroundColor(service.status.color)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { service.status == .running },
                set: { _ in onToggle() }
            ))
            .toggleStyle(.switch)
            .controlSize(.mini)
        }
        .padding(.vertical, 4)
    }
}
