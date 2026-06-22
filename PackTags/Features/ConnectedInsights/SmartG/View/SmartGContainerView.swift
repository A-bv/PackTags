import SwiftUI
import CoreData
import InstagramGraph

struct SmartGContainerView: View {
    private let gateway: any ConnectedInsightsGatewayProtocol
    private let context: NSManagedObjectContext

    init(gateway: any ConnectedInsightsGatewayProtocol, context: NSManagedObjectContext) {
        self.gateway = gateway
        self.context = context
    }

    var body: some View {
        SmartGView(gateway: gateway)
            .environment(\.managedObjectContext, context)
    }
}

#Preview {
    SmartGContainerView(
        gateway: UnavailableConnectedInsightsGateway(),
        context: PersistenceController(modelName: "SmartTags", inMemory: true).viewContext)
}
