import Foundation

@MainActor
final class ServicesViewModel: ObservableObject {
    @Published var services: [Service] = Service.defaults

    func refreshStatus() {
        Task {
            for i in services.indices {
                let running = await BrewServiceManager.isRunning(services[i].id)
                services[i].status = running ? .running : .stopped
            }
        }
    }

    func toggle(_ service: Service) {
        guard let i = services.firstIndex(where: { $0.id == service.id }) else { return }
        services[i].status = .starting
        Task {
            let shouldStart = service.status != .running
            let ok = await BrewServiceManager.toggle(service.id, start: shouldStart)
            services[i].status = ok ? (shouldStart ? .running : .stopped) : .error
        }
    }
}
