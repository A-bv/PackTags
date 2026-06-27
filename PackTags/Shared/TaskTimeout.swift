import Foundation

/// Runs `operation`, throwing `TimedOutError` if it doesn't finish within `seconds`.
///
/// Structured: the work and a timeout sleep race in a task group, so a parent task
/// cancelling propagates into `operation`, and the loser is cancelled once one wins.
/// `operation` is taken as an opaque `@Sendable @MainActor` closure so any non-Sendable
/// values it touches (network / Core Data model types) stay inside it and out of the task
/// group's region analysis — passing a non-Sendable type through the group child directly
/// trips the region-based isolation checker under strict concurrency.
func withThrowingTimeout(
    seconds: Double,
    _ operation: @escaping @Sendable @MainActor () async throws -> Void
) async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
        group.addTask { try await operation() }
        group.addTask {
            try await Task.sleep(for: .seconds(seconds))
            throw TimedOutError()
        }
        try await group.next()   // whichever finishes first wins
        group.cancelAll()        // cancel the loser
    }
}

/// Thrown by `withThrowingTimeout` when the operation outlasts its deadline.
struct TimedOutError: Error {}
