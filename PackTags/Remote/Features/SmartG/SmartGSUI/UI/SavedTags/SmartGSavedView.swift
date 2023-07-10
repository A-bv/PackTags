//
//  File.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 08.07.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

struct SmartGSavedTagsView: View {
    @FetchRequest(sortDescriptors: []) var hashtags: FetchedResults<Hashtag>
    @Environment(\.managedObjectContext) var moc
    private enum Strings {
        static let unknownHashtagTitle = "Unknown"
        static let smartGSavedTagsFooter = "Instagram allows only 30 saved hashtags per week."
        static func savedHashtagCount(count: Int) -> String {
            return "Count: \(count)"
        }
        static let savedHashtagsHeadline: String = "Saved Hashtags"
        static let left = "left"
        static let days = "days"
    }
    
    private enum Constants {
        static let sevenDaysSeconds: TimeInterval = 7 * 24 * 60 * 60
        static let sevenDays: Int = 7
        static let headerHeight: CGFloat = 50
    }
    
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            VStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 24))
                        .foregroundColor(Color("Color4"))
                        .padding()
                }
                
                List {
                    Section {
                        ForEach(hashtags, id: \.self) { hashtag in
                            SmartGSavedTagsCell(
                                title: hashtag.title ?? Strings.unknownHashtagTitle,
                                date: timeLeft(date: hashtag.addDate ?? Date()) ?? "")
                        }
                        // .onDelete(perform: removeHashtag)
                    } header: {
                        VStack(alignment: .leading) {
                            Text(Strings.savedHashtagsHeadline)
                                .font(.headline)
                                .foregroundColor(Color("Color4"))
                            
                            Text(Strings.savedHashtagCount(count: hashtags.count))
                                .font(.caption)
                                .textCase(.lowercase)
                            Spacer()
                        }
                        
                        
                    } footer: {
                        Text(Strings.smartGSavedTagsFooter)
                    }
                }
                .environment(\.defaultMinListHeaderHeight, Constants.headerHeight)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
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
    static var dataController: DataController = {
        let controller = DataController()
        let context = controller.persistantContainer.viewContext
        
        let hashtagTitles = [
            "Example Hashtag 1",
            "Example Hashtag 2",
            "Example Hashtag 3"
        ]
        let hashtags = hashtagTitles.map { title -> Hashtag in
            let hashtag = Hashtag(context: context)
            hashtag.title = title
            hashtag.addDate = Date()
            return hashtag
        }
        
        return controller
    }()
    
    static var previews: some View {
        Group {
            SmartGSavedTagsView(isPresented: .constant(true))
                .previewDisplayName("Hashtags Preview")
                .environment(\.managedObjectContext, dataController.persistantContainer.viewContext)
                .preferredColorScheme(.light) // Preview in light mode

            SmartGSavedTagsView(isPresented: .constant(true))
                .previewDisplayName("Hashtags Preview")
                .environment(\.managedObjectContext, dataController.persistantContainer.viewContext)
                .preferredColorScheme(.dark) // Preview in dark mode
        }
        
    }
}
