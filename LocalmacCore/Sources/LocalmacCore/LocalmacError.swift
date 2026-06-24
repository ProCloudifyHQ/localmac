import Foundation

public enum LocalmacError: LocalizedError {
    case serviceStartFailed(String, String)
    case serviceStopFailed(String, String)
    case installFailed(String, String)
    case phpSwitchFailed(String, String)
    case ioncubeDownloadFailed(String)
    case sslFailed(String)
    case databaseFailed(String)
    case wordpressInstallFailed(String)
    case laravelInstallFailed(String)
    case permissionDenied(String)

    public var errorDescription: String? {
        switch self {
        case .serviceStartFailed(let s, let e): return "Failed to start \(s): \(e)"
        case .serviceStopFailed(let s, let e):  return "Failed to stop \(s): \(e)"
        case .installFailed(let p, let e):      return "Failed to install \(p): \(e)"
        case .phpSwitchFailed(let v, let e):    return "Failed to switch to PHP \(v): \(e)"
        case .ioncubeDownloadFailed(let e):     return "ionCube install failed: \(e)"
        case .sslFailed(let e):                 return "SSL error: \(e)"
        case .databaseFailed(let e):            return "Database error: \(e)"
        case .wordpressInstallFailed(let e):    return "WordPress install failed: \(e)"
        case .laravelInstallFailed(let e):      return "Laravel install failed: \(e)"
        case .permissionDenied(let e):          return "Permission denied: \(e)"
        }
    }
}
