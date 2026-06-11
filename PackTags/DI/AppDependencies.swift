import Foundation

struct AppDependencies {
    let persistence: PersistenceController
    let themeRepository: any ThemeRepositoryProtocol
    let appSettings: any AppSettingsProtocol
    let connectedInsights: any ConnectedInsightsCoordinating
}
