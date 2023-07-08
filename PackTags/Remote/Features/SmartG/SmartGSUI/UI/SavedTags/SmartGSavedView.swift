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
        static let hashtags = "Hashtags"
    }
    
    var body: some View {
        VStack {
            Text(Strings.hashtags)
                .font(.headline)
                .padding()
            
            List {
                ForEach(hashtags, id: \.self) { hashtag in
                    SmartGSavedTagsCell(
                        title: hashtag.title ?? Strings.unknownHashtagTitle,
                        date: hashtag.addDate ?? Date())
                }
                .onDelete(perform: removeHashtag)
            }
            .font(.body)
            .padding()
        }
    }
    
    func removeHashtag(at offsets: IndexSet) {
        for index in offsets {
            let hashtag = hashtags[index]
            moc.delete(hashtag)
        }
    }
}


struct SmartGSavedTagsView_Previews: PreviewProvider {
    static var previews: some View {
        SmartGSavedTagsView()
            .previewDisplayName("Hashtags Preview")
    }
}
