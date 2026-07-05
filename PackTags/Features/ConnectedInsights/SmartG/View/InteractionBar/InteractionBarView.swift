import SwiftUI
import NeumorphicSwiftUI

struct InteractionBarView: View {
    @Bindable var smartGViewModel: SmartGViewModel

    @FocusState private var showKeyBoard: Bool

    private enum Constants {
        static let textFieldCornerRadius: CGFloat = 15
    }

    private enum Strings {
        static let popoverTitle = "Top 10 hashtags copied!".localized()
        static let popoverMessage =
            "The most used hashtags of the page were copied into the clipboard.".localized()
        static let popoverDismissButton = "Ok".localized()
        static let enterHashtagPlaceholder = "Enter a hashtag".localized()
        static let copyTopHashtags = "Copy top hashtags".localized()
        static let savedHashtags = "Saved Hashtags".localized()
    }

    var textField: some View {
        HStack {
            Image(systemName: "number.square.fill")
            TextField(Strings.enterHashtagPlaceholder, text: $smartGViewModel.hashtagEntry)
                .disableAutocorrection(true)
                .focused($showKeyBoard)
                .onSubmit {
                    refresh()
                }
        }
        .padding(10)
        .foregroundColor(.white)
        .font(.headline)
        .background(Color(UIColor.lightGray).opacity(0.5))
        .cornerRadius(Constants.textFieldCornerRadius)
    }

    var body: some View {
        HStack {
            textField

            Spacer()
            Spacer()

            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .soft)
                impactMed.impactOccurred()
                smartGViewModel.showingAlert = true
                UIPasteboard.general.string = smartGViewModel.topHashtags.joined(separator: " ")

            } label: {
                Image(systemName: "paperplane.circle")
                    .foregroundColor(.brandAccent)
            }
            .buttonStyle(ColorfulButtonStyle())
            .accessibilityLabel(Text(Strings.copyTopHashtags))
            .alert(isPresented: $smartGViewModel.showingAlert) {
                Alert(
                    title: Text(Strings.popoverTitle),
                    message: Text(Strings.popoverMessage),
                    dismissButton: .default(Text(Strings.popoverDismissButton)))
            }

            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .soft)
                impactMed.impactOccurred()
                smartGViewModel.showingPopover = true
            } label: {
                Image(systemName: "info.circle")
                    .foregroundColor(.brandAccent)
            }
            .buttonStyle(ColorfulButtonStyle())
            .accessibilityLabel(Text(Strings.savedHashtags))
            .popover(isPresented: $smartGViewModel.showingPopover) {
                SmartGSavedTagsView(isPresented: $smartGViewModel.showingPopover)
            }
        }
        .padding(.horizontal)
    }

    private func refresh() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        showKeyBoard = false
        // Fire-and-forget is safe here: the view model tags each search with a generation
        // and drops superseded results, so an overlapping or post-dismissal completion
        // can't corrupt state. Persisting the searched hashtag is the view model's job.
        Task { _ = await smartGViewModel.submitSearch() }
    }
}

#Preview {
    InteractionBarView(
        smartGViewModel: SmartGViewModel(
            gateway: UnavailableConnectedInsightsGateway(),
            hashtagRepository: CoreDataHashtagRepository(
                context: PersistenceController(modelName: "SmartTags", inMemory: true).viewContext)))
    .padding()
}
