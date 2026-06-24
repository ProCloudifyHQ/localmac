import Foundation

enum BrewServiceManager {
    static func isRunning(_ service: String) async -> Bool {
        let output = await shell("/opt/homebrew/bin/brew services list")
        return output.contains("\(service) started")
    }

    static func toggle(_ service: String, start: Bool) async -> Bool {
        let action = start ? "start" : "stop"
        let result = await shell("/opt/homebrew/bin/brew services \(action) \(service)")
        return !result.contains("Error")
    }

    @discardableResult
    static func shell(_ command: String) async -> String {
        await withCheckedContinuation { continuation in
            let task = Process()
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            task.launchPath = "/bin/zsh"
            task.arguments = ["-c", command]
            task.terminationHandler = { _ in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                continuation.resume(returning: String(data: data, encoding: .utf8) ?? "")
            }
            try? task.run()
        }
    }
}
