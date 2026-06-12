import SwiftUI
import InstagramGraph

private enum Strings {
    static let defaultHashtag = ""
    static let defaultHashtagWithoutHash = "travel"
}

struct SmartGView: View {
    @StateObject var smartGViewModel: SmartGViewModel
    
    @State var hashtagEntry: String = Strings.defaultHashtag
    @State var showingAlert = false
    
    @State var showingPopover = false
    @State var loading = true
    @State var isErrorState = false
    
    //Network Status
    @StateObject var monitor = NetworkMonitor()

    init(gateway: any ConnectedInsightsGatewayProtocol) {
        _smartGViewModel = StateObject(
            wrappedValue: SmartGViewModel(gateway: gateway))
    }
    
    var body: some View {
        ZStack{
            Color.bgFillColor.ignoresSafeArea()
            if !monitor.isConnected {
                OfflineView()
            } else {
                VStack() {
                    SmartGHeader()
                    interactionBar
                    Spacer()
                    if loading {
                        LoadingView(loading: $loading).opacity(0.8)
                    } else if isErrorState {
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
            loading = true
            isErrorState = await smartGViewModel.fetch(hashtag: Strings.defaultHashtagWithoutHash)
            loading = false
        }
    }
    
    var interactionBar: some View {
        InteractionBarView(
            loading: $loading,
            showingPopover: $showingPopover,
            hashtagEntry: $hashtagEntry,
            showingAlert: $showingAlert, 
            isErrorState: $isErrorState,
            smartGViewModel: smartGViewModel)
    }
}

struct SmartGView_Previews: PreviewProvider {
    static var previews: some View {
        SmartGView(gateway: UnavailableConnectedInsightsGateway())
    }
}
