import SwiftUI

struct InteractionBarView: View {
    @Binding var loading: Bool
    @Binding var showingPopover: Bool
    @Binding var hashtagEntry: String
    @Binding var showingAlert: Bool
    @Binding var isErrorState: Bool
    @State var searchedHashtag: String = ""

    @Environment(\.managedObjectContext) var moc
    @FocusState private var showKeyBoard: Bool

    @FetchRequest(entity: Hashtag.entity(), sortDescriptors: [])
    var hashtags: FetchedResults<Hashtag>
    
    var smartGViewModel: SmartGViewModel
    private enum Constants {
        static let textFieldCornerRadius: CGFloat = 15
    }
    
    private enum Strings {
        static let popoverTitle = "Top 10 hashtags copied!".localized()
        static let popoverMessage =
            "The most used hashtags of the page were copied into the clipboard.".localized()
        static let popoverDismissButton = "Ok"
        static let enterHashtagPlaceholder = "Enter a hashtag".localized()
    }
    
    var textField: some View {
        HStack {
            Image(systemName: "number.square.fill")
            TextField(Strings.enterHashtagPlaceholder, text: $hashtagEntry)
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
                showingAlert = true
                UIPasteboard.general.string = smartGViewModel.topHashtags.joined(separator: " ")
                
            } label: {
                Image(systemName: "paperplane.circle")
                    .foregroundColor(Color("Color4"))
            }
            .buttonStyle(ColorfulButtonStyle())
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(Strings.popoverTitle),
                    message: Text(Strings.popoverMessage),
                    dismissButton: .default(Text(Strings.popoverDismissButton)))
            }

            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .soft)
                impactMed.impactOccurred()
                showingPopover = true
            } label: {
                Image(systemName: "info.circle")
                    .foregroundColor(Color("Color4"))
            }
            .buttonStyle(ColorfulButtonStyle())
            .popover(isPresented: $showingPopover) {
                SmartGSavedTagsView(isPresented: $showingPopover)
            }
        }
        .padding(.horizontal)
    }
    
    private func refresh() {
        let impactMed = UIImpactFeedbackGenerator(style: .soft)
        impactMed.impactOccurred()
        let newEntry = hashtagEntry.filter { $0 != "#" }
        if searchedHashtag != newEntry {
            searchedHashtag = newEntry
            loading = true
            Task {
                isErrorState = await smartGViewModel.fetch(hashtag: searchedHashtag)
                loading = false
            }
            updateHashtag(entry: hashtagEntry)
        }
        showKeyBoard = false
    }
}

struct InteractionBarView_Previews: PreviewProvider {
    static var previews: some View {
        @FetchRequest(sortDescriptors: []) var hashtags: FetchedResults<Hashtag>
        
        return InteractionBarView(
            loading: .constant(false),
            showingPopover: .constant(false),
            hashtagEntry: .constant(""),
            showingAlert: .constant(false),
            isErrorState: .constant(false),
            smartGViewModel: SmartGViewModel(gateway: UnavailableConnectedInsightsGateway()))
        .padding()
    }
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
        let hashtag = Hashtag(context: moc)
        hashtag.id = UUID()
        hashtag.title = "\(hastagTitle)"
        hashtag.addDate = Date()
        try? moc.save()
    }
}
