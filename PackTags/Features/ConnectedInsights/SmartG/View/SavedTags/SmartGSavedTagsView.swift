import SwiftUI

struct SmartGSavedTagsView: View {
    private enum Strings {
        static let smartGSavedTagsFooter = "Instagram allows only 30 saved hashtags per week.".localized()
        static func savedHashtagCount(count: Int) -> String {
            return "Count: \(count)"
        }
        static let savedHashtagsHeadline: String = "Saved Hashtags".localized()
        static let left = "left"
        static let days = "days"
    }
    
    private enum Constants {
        static let sevenDays: Int = 7
        static let headerHeight: CGFloat = 50
        static let tintColor = Color("Color4")
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
        let currentDate = Date()
        let calendar = Calendar.current
        
        guard let futureDate = calendar.date(byAdding: .day, value: Constants.sevenDays, to: date) else {
            return nil
        }
        
        let components = calendar.dateComponents([.day], from: currentDate, to: futureDate)
        
        if let days = components.day {
            let daysString = String(days)
            return "\(daysString) \(Strings.days) \(Strings.left)"
        }
        
        return nil
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
