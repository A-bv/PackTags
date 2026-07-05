import SwiftUI
import CoreData
import InstagramGraph

struct SmartGContainerView: View {
    private let viewModel: SmartGViewModel
    private let context: NSManagedObjectContext

    init(gateway: any ConnectedInsightsGatewayProtocol, context: NSManagedObjectContext) {
        self.viewModel = SmartGViewModel(
            gateway: gateway,
            hashtagRepository: CoreDataHashtagRepository(context: context))
        self.context = context
    }

    var body: some View {
        SmartGView(viewModel: viewModel)
            // The saved-tags sheet reads the store reactively through @FetchRequest;
            // all writes go through the view model's HashtagRepository.
            .environment(\.managedObjectContext, context)
    }
}

#Preview {
    SmartGContainerView(
        gateway: UnavailableConnectedInsightsGateway(),
        context: PersistenceController(modelName: "SmartTags", inMemory: true).viewContext)
}
