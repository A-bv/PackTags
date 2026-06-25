import SwiftUI
import NeumorphicSwiftUI

struct InteractionBarView: View {
    @Bindable var smartGViewModel: SmartGViewModel

    @Environment(\.managedObjectContext) var moc
    @FocusState private var showKeyBoard: Bool

    @FetchRequest(entity: HashtagEntity.entity(), sortDescriptors: [])
    var hashtags: FetchedResults<HashtagEntity>

    private enum Constants {
        static let textFieldCornerRadius: CGFloat = 15
    }

    private enum Strings {
        static let popoverTitle = "Top 10 hashtags copied!".localized()
        static let popoverMessage =
            "The most used hashtags of the page were copied into the clipboard.".localized()
        static let popoverDismissButton = "Ok".localized()
        static let enterHashtagPlaceholder = "Enter a hashtag".localized()
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
            .popover(isPresented: $smartGViewModel.showingPopover) {
                SmartGSavedTagsView(isPresented: $smartGViewModel.showingPopover)
            }
        }
        .padding(.horizontal)
    }

    private func refresh() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        let entry = smartGViewModel.hashtagEntry
        showKeyBoard = false
        Task {
            if await smartGViewModel.submitSearch() {
                updateHashtag(entry: entry)
            }
        }
    }
}

#Preview {
    InteractionBarView(
        smartGViewModel: SmartGViewModel(gateway: UnavailableConnectedInsightsGateway()))
    .padding()
}

// MARK: - Functions
extension InteractionBarView {
    private func updateHashtag (entry: String) {
        if let index = hashtags.firstIndex(where: { $0.title == entry }) {
            moc.delete(hashtags[index])
        }
        saveHashtag(hastagTitle: entry)
    }

    private func saveHashtag(hastagTitle: String) {
        pruneExpiredHashtags()
        let hashtag = HashtagEntity(context: moc)
        hashtag.id = UUID()
        hashtag.title = hastagTitle
        hashtag.addDate = Date()
        try? moc.save()
    }

    /// Drops entries past Instagram's 7-day window so the saved list stays bounded and
    /// every remaining row still has time left on its countdown.
    private func pruneExpiredHashtags() {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        for hashtag in hashtags where (hashtag.addDate ?? Date()) < cutoff {
            moc.delete(hashtag)
        }
    }
}
