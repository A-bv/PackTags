import SwiftUI

struct FBLoginView: View {
    private enum Strings {
        static let trackingOn = "App tracking on".localized()
        static let trackingOff = "App tracking off".localized()
        static let trackingOffDetail = "Meta features need app tracking. Turn on Allow Tracking in Settings.".localized()
        static let manage = "Manage".localized()
        static let setupHelp = "Setup".localized()
        static let reset = "Reset Facebook Login".localized()
        static let wrongSetupTitle = "Edit Your Setup".localized()
        static let troubleshooting = "troubleShootingAlertMessage".localized()
        static let enableTracking = "Enable Tracking".localized()
        static let ok = "OK"
        static let connectedTitle = "Connected!".localized()
        static let connectedMessage = "You can now access analytics and generate hashtags.".localized()
        static let trackingInfoTitle = "Why tracking?".localized()
        static let trackingInfoMessage = "trackingInfoMessage".localized()
    }

    @State private var viewModel: FBLoginViewModel
    private let appSettings: any AppSettingsProtocol
    private let onConnected: () -> Void
    private let onClose: () -> Void
    /// In the feature flow the screen is a step (leave once connected); from Settings
    /// it's the destination, so a passive re-validation must NOT auto-dismiss it.
    private let dismissWhenAlreadyConnected: Bool

    @State private var showInfo = false
    @State private var showWrongSetup = false
    @State private var showTrackingInfo = false
    @State private var showConnected = false

    init(
        viewModel: FBLoginViewModel,
        appSettings: any AppSettingsProtocol,
        dismissWhenAlreadyConnected: Bool = true,
        onConnected: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.appSettings = appSettings
        self.dismissWhenAlreadyConnected = dismissWhenAlreadyConnected
        self.onConnected = onConnected
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VisualEffectBlurView().ignoresSafeArea()

                VStack {
                    trackingRow
                    Spacer()
                    FacebookLoginButton(
                        permissions: viewModel.loginPermissions,
                        onComplete: { error in
                            Task { await viewModel.didCompleteLogin(error: error) }
                        },
                        onLogOut: { viewModel.resetFacebookSession() })
                    .fixedSize()
                    .disabled(viewModel.isValidating)
                    Spacer()
                    resetButton
                }
                .padding()

                if viewModel.isValidating {
                    ProgressView().scaleEffect(1.4)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Strings.setupHelp) { showInfo = true }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onClose) { Image(systemName: "xmark") }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .task {
                if viewModel.hasSeenSetupInfo { await viewModel.onAppear() }
            }
            .onAppear {
                if !viewModel.hasSeenSetupInfo && !showInfo { showInfo = true }
            }
            .fullScreenCover(isPresented: $showInfo, onDismiss: {
                Task { await viewModel.onAppear() }
            }) {
                SetupInfoView(appSettings: appSettings, onClose: { showInfo = false })
                    .presentationBackground(.clear)
            }
            .onChange(of: viewModel.result) { _, result in
                switch result {
                case .connected:
                    if viewModel.connectedViaLogin {
                        showConnected = true
                    } else {
                        viewModel.clearResult()
                        if dismissWhenAlreadyConnected { onConnected() }
                    }
                case .sessionExpired, .failed:
                    showWrongSetup = true
                case .none:
                    break
                }
            }
            .alert(Strings.wrongSetupTitle, isPresented: $showWrongSetup) {
                if !viewModel.isTrackingAuthorized {
                    Button(Strings.enableTracking) {
                        viewModel.clearResult()
                        Task { await viewModel.handleTrackingTap() }
                    }
                }
                Button(Strings.ok, role: .cancel) { viewModel.clearResult() }
            } message: {
                Text(wrongSetupMessage)
            }
            .alert(Strings.trackingInfoTitle, isPresented: $showTrackingInfo) {
                Button(Strings.ok, role: .cancel) {}
            } message: {
                Text(Strings.trackingInfoMessage)
            }
            .alert(Strings.connectedTitle, isPresented: $showConnected) {
                Button(Strings.ok) {
                    viewModel.clearResult()
                    onConnected()
                }
            } message: {
                Text(Strings.connectedMessage)
            }
        }
    }

    /// Always-visible tracking status. iOS won't let the app flip ATT either way, so
    /// "Manage" just opens the app's Settings page where the user can turn Allow
    /// Tracking on or off. The detail line nudges them when it's off (the token-breaking
    /// state), but the path to change it is there whether it's on or off.
    private var trackingRow: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: viewModel.isTrackingAuthorized ? "checkmark.circle" : "exclamationmark.triangle.fill")
                    .foregroundStyle(viewModel.isTrackingAuthorized ? Color.secondary : Color.orange)
                Text(viewModel.isTrackingAuthorized ? Strings.trackingOn : Strings.trackingOff)
                    .font(.footnote)
                Spacer()
                Button(Strings.manage) { Task { await viewModel.handleTrackingTap() } }
                    .font(.footnote)
                Button { showTrackingInfo = true } label: {
                    Image(systemName: "info.circle")
                }
            }
            if !viewModel.isTrackingAuthorized {
                Text(Strings.trackingOffDetail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 40)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var resetButton: some View {
        Button(Strings.reset) { viewModel.resetFacebookSession() }
            .font(.footnote)
            .tint(.secondary)
            .disabled(viewModel.isValidating)
    }

    private var wrongSetupMessage: String {
        // Tracking off is the most common cause now (the token gets rejected), so name it.
        if !viewModel.isTrackingAuthorized {
            return Strings.trackingOffDetail
        }
        if case let .failed(message?) = viewModel.result {
            return Strings.troubleshooting + "\n\n" + message
        }
        return Strings.troubleshooting
    }
}
