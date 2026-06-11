//
//  File.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 08.07.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

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
        static let sevenDaysSeconds: TimeInterval = 7 * 24 * 60 * 60
        static let sevenDays: Int = 7
        static let headerHeight: CGFloat = 50
        static let tintColor = Color("Color4")
    }
    
    @Binding var isPresented: Bool
    @FetchRequest(entity: Hashtag.entity(), sortDescriptors: []) var hashtags: FetchedResults<Hashtag>
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
                        // .onDelete(perform: removeHashtag)
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
        hashtag: FetchedResults<Hashtag>.Element
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
    
    private func removeHashtag(at offsets: IndexSet) {
        for index in offsets {
            let hashtag = hashtags[index]
            moc.delete(hashtag)
        }
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

struct SmartGSavedTagsView_Previews: PreviewProvider {
    static var persistence: PersistenceController = {
        let persistence = PersistenceController(modelName: "SmartTags", inMemory: true)
        let context = persistence.viewContext

        let hashtagTitles = [
            "Example Hashtag 1",
            "Example Hashtag 2",
            "Example Hashtag 3"
        ]
        for title in hashtagTitles {
            let hashtag = Hashtag(context: context)
            hashtag.title = title
            hashtag.addDate = Date()
        }

        return persistence
    }()

    static var previews: some View {
        Group {
            SmartGSavedTagsView(isPresented: .constant(true))
                .previewDisplayName("Hashtags Preview")
                .environment(\.managedObjectContext, persistence.viewContext)
                .preferredColorScheme(.light)

            SmartGSavedTagsView(isPresented: .constant(true))
                .previewDisplayName("Hashtags Preview")
                .environment(\.managedObjectContext, persistence.viewContext)
                .preferredColorScheme(.dark)
        }
    }
}
