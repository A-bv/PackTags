import Foundation
import Network

@MainActor
@Observable
final class NetworkMonitor {
    @ObservationIgnored private let monitor = NWPathMonitor()

    var isConnected = true

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: DispatchQueue(label: "Monitor"))
    }
}
