import MetricKit

/// Subscribes to MetricKit and logs its diagnostic payloads (crashes, hangs, CPU/disk
/// exceptions) and daily metric payloads.
///
/// MetricKit delivers on a real device (not the simulator), aggregated daily and on the
/// first launch after a crash. The sink here is `os.Logger`, so payloads are visible in
/// Console and captured in a sysdiagnose — a dependency-free baseline for field stability.
/// A production build would instead forward `jsonRepresentation()` to a backend.
///
/// Stateless, so `@unchecked Sendable` is safe — MetricKit invokes the callbacks off the
/// main thread.
final class MetricsReporter: NSObject, MXMetricManagerSubscriber, @unchecked Sendable {
    func start() {
        MXMetricManager.shared.add(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            guard let text = String(data: payload.jsonRepresentation(), encoding: .utf8) else { continue }
            AppLogger.metrics.info("MetricKit metrics: \(text, privacy: .public)")
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            guard let text = String(data: payload.jsonRepresentation(), encoding: .utf8) else { continue }
            AppLogger.metrics.error("MetricKit diagnostic: \(text, privacy: .public)")
        }
    }
}
