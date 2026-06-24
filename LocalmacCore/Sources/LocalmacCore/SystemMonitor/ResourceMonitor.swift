import Foundation

public struct SystemStats {
    public let cpuPercent: Double
    public let memoryPercent: Double
    public let diskUsed: String
    public let diskTotal: String
    public let networkUpBytes: Int64
    public let networkDownBytes: Int64
}

public final class ResourceMonitor: @unchecked Sendable {
    public static let shared = ResourceMonitor()

    private var previousNetUp: Int64 = 0
    private var previousNetDown: Int64 = 0

    public func snapshot() async -> SystemStats {
        async let cpu  = fetchCPU()
        async let mem  = fetchMemory()
        async let disk = fetchDisk()
        async let net  = fetchNetwork()

        let (c, m, d, n) = await (cpu, mem, disk, net)
        return SystemStats(
            cpuPercent: c,
            memoryPercent: m,
            diskUsed: d.used,
            diskTotal: d.total,
            networkUpBytes: n.up,
            networkDownBytes: n.down
        )
    }

    private func fetchCPU() async -> Double {
        let out = await Shell.run("top -l 1 -s 0 | grep 'CPU usage' | awk '{print $3}' | tr -d '%'").output
        return Double(out) ?? 0
    }

    private func fetchMemory() async -> Double {
        let pages = await Shell.run("""
            vm_stat | awk '
              /Pages active/   {a=$3}
              /Pages wired/    {w=$4}
              /Pages inactive/ {i=$3}
              END { print (a+w+i)*4096 }
            '
        """).output
        let used  = Double(pages.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let total = Double(ProcessInfo.processInfo.physicalMemory)
        return total > 0 ? (used / total) * 100 : 0
    }

    private func fetchDisk() async -> (used: String, total: String) {
        let out = await Shell.run("df -h / | awk 'NR==2 {print $3, $2}'").output
        let parts = out.components(separatedBy: " ")
        return (parts.first ?? "—", parts.last ?? "—")
    }

    private func fetchNetwork() async -> (up: Int64, down: Int64) {
        let out = await Shell.run("netstat -ib | awk 'NR>1 && /en/ {up+=$10; down+=$7} END {print up, down}'").output
        let parts = out.components(separatedBy: " ")
        return (Int64(parts.first ?? "0") ?? 0, Int64(parts.last ?? "0") ?? 0)
    }
}
