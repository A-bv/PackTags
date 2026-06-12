import Foundation
import Network

@MainActor
final class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()

    @Published var isConnected = true

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: DispatchQueue(label: "Monitor"))
    }
}
