import SwiftUI

struct DashboardView: View {
    @StateObject private var monitor = SystemMonitor()

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                MetricCard(title: "CPU", value: "\(Int(monitor.cpuUsage))%", icon: "cpu", color: .blue)
                MetricCard(title: "RAM", value: "\(Int(monitor.memoryUsage))%", icon: "memorychip", color: .purple)
            }
            HStack(spacing: 12) {
                MetricCard(title: "Disk", value: monitor.diskUsage, icon: "internaldrive", color: .orange)
                MetricCard(title: "Net ↑", value: monitor.networkUpload, icon: "arrow.up.circle", color: .green)
            }
        }
        .padding(12)
        .onAppear { monitor.start() }
        .onDisappear { monitor.stop() }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(color.opacity(0.08))
        .cornerRadius(8)
    }
}
