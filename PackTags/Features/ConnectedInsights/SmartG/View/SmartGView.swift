import SwiftUI
import InstagramGraph
import NeumorphicSwiftUI

struct SmartGView: View {
    private enum Strings {
        static let loadError = "Couldn't load hashtags.\nCheck your connection and try again.".localized()
        static let retry = "Retry".localized()
    }

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
                    SmartGHeaderView()
                    InteractionBarView(smartGViewModel: smartGViewModel)
                    Spacer()
                    if smartGViewModel.loading {
                        LoadingView(loading: .constant(true)).opacity(0.8)
                    } else if smartGViewModel.isErrorState {
                        failureRetryView
                    } else if smartGViewModel.hasNoResults {
                        SmartGErrorStateView()
                    } else {
                        ScrollView{
                            VStack {
                                FloatingListView(viewModel: self.smartGViewModel)
                                StoryCardCarouselView(viewModel: smartGViewModel)
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

    /// Shown when a search throws (network / server / timeout): a clear message plus a
    /// retry that replays the last search — distinct from `SmartGErrorStateView`, which
    /// handles a successful search that simply found nothing.
    private var failureRetryView: some View {
        VStack(spacing: 16) {
            Text(Strings.loadError)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(UIColor.label))
            Button {
                Task { await smartGViewModel.retry() }
            } label: {
                Text(Strings.retry)
                    .foregroundColor(.brandAccent)
            }
            .buttonStyle(ColorfulButtonStyle())
        }
        .padding()
    }
}

#Preview {
    SmartGView(gateway: UnavailableConnectedInsightsGateway())
}
