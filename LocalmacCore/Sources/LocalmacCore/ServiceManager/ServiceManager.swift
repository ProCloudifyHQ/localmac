import Foundation

public enum ServiceID: String, CaseIterable {
    case nginx      = "nginx"
    case apache     = "httpd"
    case mysql      = "mysql"
    case mariadb    = "mariadb"
    case postgresql = "postgresql@16"
    case redis      = "redis"
    case memcached  = "memcached"
    case mailpit    = "mailpit"
    case dnsmasq    = "dnsmasq"
}

public enum ServiceState: Equatable {
    case running, stopped, error(String)
}

public actor ServiceManager {
    public static let shared = ServiceManager()

    public func start(_ service: ServiceID) async throws {
        let result = await Shell.brew("services start \(service.rawValue)")
        if !result.succeeded {
            throw LocalmacError.serviceStartFailed(service.rawValue, result.error)
        }
    }

    public func stop(_ service: ServiceID) async throws {
        let result = await Shell.brew("services stop \(service.rawValue)")
        if !result.succeeded {
            throw LocalmacError.serviceStopFailed(service.rawValue, result.error)
        }
    }

    public func restart(_ service: ServiceID) async throws {
        let result = await Shell.brew("services restart \(service.rawValue)")
        if !result.succeeded {
            throw LocalmacError.serviceStartFailed(service.rawValue, result.error)
        }
    }

    public func status(_ service: ServiceID) async -> ServiceState {
        let result = await Shell.brew("services list")
        guard result.succeeded else { return .error(result.error) }
        let lines = result.output.components(separatedBy: .newlines)
        for line in lines where line.hasPrefix(service.rawValue) {
            if line.contains("started") { return .running }
            if line.contains("error")   { return .error(line) }
            return .stopped
        }
        return .stopped
    }

    public func allStatuses() async -> [ServiceID: ServiceState] {
        let result = await Shell.brew("services list")
        guard result.succeeded else {
            return Dictionary(uniqueKeysWithValues: ServiceID.allCases.map { ($0, ServiceState.error(result.error)) })
        }
        var statuses: [ServiceID: ServiceState] = [:]
        for service in ServiceID.allCases {
            let line = result.output.components(separatedBy: .newlines)
                .first { $0.hasPrefix(service.rawValue) } ?? ""
            if line.contains("started")     { statuses[service] = .running }
            else if line.contains("error")  { statuses[service] = .error(line) }
            else                            { statuses[service] = .stopped }
        }
        return statuses
    }

    public func isInstalled(_ service: ServiceID) async -> Bool {
        let result = await Shell.brew("list --formula \(service.rawValue)")
        return result.succeeded
    }

    public func install(_ service: ServiceID) async throws {
        let result = await Shell.brew("install \(service.rawValue)")
        if !result.succeeded {
            throw LocalmacError.installFailed(service.rawValue, result.error)
        }
    }
}
