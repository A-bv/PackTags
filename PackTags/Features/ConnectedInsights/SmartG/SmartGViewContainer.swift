import SwiftUI
import CoreData
import InstagramGraph

struct SmartGViewContainer: View {
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
