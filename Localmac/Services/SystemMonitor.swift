import Foundation

@MainActor
final class SystemMonitor: ObservableObject {
    @Published var cpuUsage: Double = 0
    @Published var memoryUsage: Double = 0
    @Published var diskUsage: String = "—"
    @Published var networkUpload: String = "—"

    private var timer: Timer?

    func start() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func refresh() {
        Task {
            cpuUsage = await fetchCPU()
            memoryUsage = await fetchMemory()
            diskUsage = await fetchDisk()
        }
    }

    private func fetchCPU() async -> Double {
        let out = await BrewServiceManager.shell("top -l 1 | grep 'CPU usage' | awk '{print $3}' | tr -d '%'")
        return Double(out.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }

    private func fetchMemory() async -> Double {
        let out = await BrewServiceManager.shell(
            "vm_stat | awk '/Pages active/ {active=$3} /Pages wired/ {wired=$4} END {print (active+wired)*4096/1024/1024}'"
        )
        let used = Double(out.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let total = Double(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024
        return total > 0 ? (used / total) * 100 : 0
    }

    private func fetchDisk() async -> String {
        let out = await BrewServiceManager.shell("df -h / | awk 'NR==2 {print $3\"/\"$2}'")
        return out.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
