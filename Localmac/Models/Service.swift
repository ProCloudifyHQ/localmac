import SwiftUI

enum ServiceStatus {
    case running, stopped, starting, error

    var label: String {
        switch self {
        case .running:  return "Running"
        case .stopped:  return "Stopped"
        case .starting: return "Starting..."
        case .error:    return "Error"
        }
    }

    var color: Color {
        switch self {
        case .running:  return .green
        case .stopped:  return .secondary
        case .starting: return .orange
        case .error:    return .red
        }
    }
}

struct Service: Identifiable {
    let id: String          // homebrew service name e.g. "nginx"
    let name: String        // display name
    let icon: String        // SF Symbol
    var status: ServiceStatus

    static let defaults: [Service] = [
        Service(id: "nginx",      name: "Nginx",       icon: "network",              status: .stopped),
        Service(id: "httpd",      name: "Apache",      icon: "server.rack",          status: .stopped),
        Service(id: "mysql",      name: "MySQL",       icon: "cylinder",             status: .stopped),
        Service(id: "mariadb",    name: "MariaDB",     icon: "cylinder.split.1x2",   status: .stopped),
        Service(id: "postgresql", name: "PostgreSQL",  icon: "elephant",             status: .stopped),
        Service(id: "redis",      name: "Redis",       icon: "memorychip",           status: .stopped),
        Service(id: "memcached",  name: "Memcached",   icon: "bolt",                 status: .stopped),
        Service(id: "mailpit",    name: "Mailpit",     icon: "envelope",             status: .stopped),
        Service(id: "dnsmasq",    name: "DNSMasq",     icon: "dot.radiowaves.left.and.right", status: .stopped),
    ]
}
