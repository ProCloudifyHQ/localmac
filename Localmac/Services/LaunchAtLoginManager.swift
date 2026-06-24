import ServiceManagement

enum LaunchAtLoginManager {
    static func set(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                // Silently ignore — user can change manually in System Settings
            }
        }
    }
}
