import Foundation

public struct ShellResult {
    public let output: String
    public let error: String
    public let exitCode: Int32

    public var succeeded: Bool { exitCode == 0 }
}

public enum Shell {
    public static let brew = "/opt/homebrew/bin/brew"
    public static let zsh  = "/bin/zsh"

    @discardableResult
    public static func run(_ command: String, env: [String: String]? = nil) async -> ShellResult {
        await withCheckedContinuation { continuation in
            let task = Process()
            let outPipe = Pipe()
            let errPipe = Pipe()

            task.launchPath = zsh
            task.arguments  = ["-c", command]
            task.standardOutput = outPipe
            task.standardError  = errPipe

            if let env {
                var merged = ProcessInfo.processInfo.environment
                env.forEach { merged[$0] = $1 }
                task.environment = merged
            }

            task.terminationHandler = { _ in
                let out = String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
                let err = String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
                continuation.resume(returning: ShellResult(output: out.trimmingCharacters(in: .whitespacesAndNewlines),
                                                           error: err.trimmingCharacters(in: .whitespacesAndNewlines),
                                                           exitCode: task.terminationStatus))
            }

            do { try task.run() } catch {
                continuation.resume(returning: ShellResult(output: "", error: error.localizedDescription, exitCode: 1))
            }
        }
    }

    public static func brew(_ args: String) async -> ShellResult {
        await run("\(brew) \(args)")
    }
}
