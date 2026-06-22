import SwiftUI

/// Explains the Instagram Business/Creator + linked-Page requirement. SwiftUI port of
/// the former `InfoSetupIGCreatorViewController`.
struct SetupInfoView: View {
    private enum Strings {
        static let intro = "Meta features are only available to Creator/Business Instagram accounts connected to a Facebook page.".localized()
        static let topLabel = "Creator /Business account:".localized()
        static let topText = "topTextViewText".localized()
        static let bottomLabel = "If you do not have a connected page:".localized()
        static let bottomText = "bottomTextViewText".localized()
        static let openInstagram = "Open Instagram".localized()
    }

    private enum Constants {
        static let contentPadding: CGFloat = 28
        static let sectionSpacing: CGFloat = 40
        static let titleStepsSpacing: CGFloat = 14
        static let stepSpacing: CGFloat = 10
        static let iconSize: CGFloat = 30
        static let iconTitleSpacing: CGFloat = 8
        static let bulletTextSpacing: CGFloat = 10
        static let bulletSize: CGFloat = 5
        /// Steps indent so they line up under the title text, past the icon column.
        static let stepsIndent = iconSize + iconTitleSpacing
    }

    private enum Links {
        static let app = "instagram://app"
        static let web = "https://instagram.com"
    }

    private enum SectionIcon {
        case instagram
        case facebook
    }

    let appSettings: any AppSettingsProtocol
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                VisualEffectBlurView().ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
                        Text(Strings.intro)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        section(icon: .instagram, label: Strings.topLabel, text: Strings.topText)
                        section(icon: .facebook, label: Strings.bottomLabel, text: Strings.bottomText)
                    }
                    .padding(Constants.contentPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onClose) { Image(systemName: "xmark") }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                Button(Strings.openInstagram) {
                    ExternalLinkOpener.openAppURL(appURL: Links.app, webURL: Links.web)
                }
                .tint(Color(uiColor: .customPurple))
                .padding()
            }
        }
        .onAppear { appSettings.setupInfoShown = true }
    }

    private func section(icon: SectionIcon, label: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: Constants.titleStepsSpacing) {
            HStack(spacing: Constants.iconTitleSpacing) {
                sectionIcon(icon)
                Text(label).font(.headline)
            }
            VStack(alignment: .leading, spacing: Constants.stepSpacing) {
                ForEach(steps(from: text), id: \.self) { step in
                    HStack(alignment: .firstTextBaseline, spacing: Constants.bulletTextSpacing) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: Constants.bulletSize))
                            .foregroundStyle(.secondary)
                        Text(step).font(.body)
                    }
                }
            }
            .padding(.leading, Constants.stepsIndent)
        }
    }

    @ViewBuilder
    private func sectionIcon(_ icon: SectionIcon) -> some View {
        switch icon {
        case .instagram:
            Image("igColor")
                .resizable()
                .frame(width: Constants.iconSize, height: Constants.iconSize)
        case .facebook:
            // No Facebook brand asset ships with the app and SF Symbols have no Facebook
            // logo, so we use a link glyph (the section is about *linking* a page) tinted
            // Facebook blue. Swap for an `fbColor` asset if one is added.
            Image(systemName: "link")
                .font(.system(size: Constants.iconSize * 0.6))
                .foregroundStyle(.facebookBlue)
                .frame(width: Constants.iconSize, height: Constants.iconSize)
        }
    }

    /// Splits a localized step block into clean lines, stripping the raw bullet glyphs
    /// so the view can render its own.
    private func steps(from text: String) -> [String] {
        text
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "⭑✶★• \t")) }
            .filter { !$0.isEmpty }
    }
}

#Preview {
    SetupInfoView(appSettings: UserDefaultsAppSettings(), onClose: {})
}
