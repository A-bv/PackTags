import SwiftUI
import InstagramGraph

struct SmartGView: View {
    @State var smartGViewModel: SmartGViewModel
    @State private var monitor: NetworkMonitor

    init(gateway: any ConnectedInsightsGatewayProtocol, monitor: NetworkMonitor = NetworkMonitor()) {
        _smartGViewModel = State(initialValue: SmartGViewModel(gateway: gateway))
        _monitor = State(initialValue: monitor)
    }

    var body: some View {
        ZStack{
            Color.bgFillColor.ignoresSafeArea()
            if !monitor.isConnected {
                OfflineView()
            } else {
                VStack() {
                    SmartGHeader()
                    InteractionBarView(smartGViewModel: smartGViewModel)
                    Spacer()
                    if smartGViewModel.loading {
                        LoadingView(loading: .constant(true)).opacity(0.8)
                    } else if smartGViewModel.isErrorState {
                        SmartGErrorStateView()
                    } else {
                        ScrollView{
                            VStack {
                                FloatingListView(viewModel: self.smartGViewModel)
                                collection
                                    .padding(.vertical)
                            }
                        }
                        .ignoresSafeArea(.keyboard)
                    }
                    Spacer()
                }
            }
        }
        .task {
            await smartGViewModel.loadDefaultFeed()
        }
    }
}

struct SmartGView_Previews: PreviewProvider {
    static var previews: some View {
        SmartGView(gateway: UnavailableConnectedInsightsGateway())
    }
}
