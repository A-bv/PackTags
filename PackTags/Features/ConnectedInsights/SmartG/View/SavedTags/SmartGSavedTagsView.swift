import SwiftUI

struct SmartGSavedTagsView: View {
    private enum Strings {
        static let smartGSavedTagsFooter = "Instagram allows only 30 saved hashtags per week.".localized()
        static func savedHashtagCount(count: Int) -> String {
            String(format: "Saved: %d".localized(), count)
        }
        static let savedHashtagsHeadline = "Saved Hashtags".localized()
        static let close = "Close".localized()
        static func daysLeft(_ days: Int) -> String {
            switch days {
            case ...0: return "Expired".localized()
            case 1: return "1 day left".localized()
            default: return String(format: "%d days left".localized(), days)
            }
        }
    }
    
    private enum Constants {
        static let sevenDays: Int = 7
        static let headerHeight: CGFloat = 50
        static let tintColor = Color.brandAccent
    }
    
    @Binding var isPresented: Bool
    @FetchRequest(entity: HashtagEntity.entity(), sortDescriptors: []) var hashtags: FetchedResults<HashtagEntity>
    @Environment(\.managedObjectContext) var moc
    
    private var button: some View {
        Button(action: {
            isPresented = false
        }) {
            Image(systemName: "chevron.down")
                .font(.system(size: 24))
                .foregroundColor(Constants.tintColor)
                .padding(.top)
        }
        .accessibilityLabel(Text(Strings.close))
    }
    
    private var header: some View {
        VStack(alignment: .leading) {
            Text(Strings.savedHashtagsHeadline)
                .font(.headline)
                .foregroundColor(Constants.tintColor)
            
            Text(Strings.savedHashtagCount(count: hashtags.count))
                .font(.caption)
                .textCase(.lowercase)
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                button
                List {
                    Section {
                        ForEach(hashtags, id: \.self) { hashtag in
                            makeCell(hashtag: hashtag)
                        }
                    } header: {
                        header
                            .padding(.bottom)
                    } footer: {
                        Text(Strings.smartGSavedTagsFooter)
                    }
                }
                .environment(\.defaultMinListHeaderHeight, Constants.headerHeight)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    private func makeCell(
        hashtag: FetchedResults<HashtagEntity>.Element
    ) -> SmartGSavedTagsCell? {
        guard
            let title = hashtag.title,
            let date = hashtag.addDate,
            let dateString =  timeLeft(date: date)
        else {
            return nil
        }
                    
        return SmartGSavedTagsCell(
            title: title,
            date: dateString)
    }
    
    private func timeLeft(date: Date) -> String? {
        let calendar = Calendar.current

        guard let futureDate = calendar.date(byAdding: .day, value: Constants.sevenDays, to: date) else {
            return nil
        }

        let components = calendar.dateComponents([.day], from: Date(), to: futureDate)
        guard let days = components.day else { return nil }
        return Strings.daysLeft(days)
    }
}

#Preview {
    let persistence = PersistenceController(modelName: "SmartTags", inMemory: true)
    for title in ["Example Hashtag 1", "Example Hashtag 2", "Example Hashtag 3"] {
        let hashtag = HashtagEntity(context: persistence.viewContext)
        hashtag.title = title
        hashtag.addDate = Date()
    }
    return SmartGSavedTagsView(isPresented: .constant(true))
        .environment(\.managedObjectContext, persistence.viewContext)
}
