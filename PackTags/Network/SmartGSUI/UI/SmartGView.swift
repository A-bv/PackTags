//
//  SmartGen_SwiftUI.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26/11/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

private enum Constants {
    static let collectionInterMediasPadding: CGFloat = 10
    static let collectionPadding: CGFloat = 5
    static let interactionBarPadding: CGFloat = 20
}

private enum Strings {
    static let defaultHashtag = "#travel"
    static let defaultHashtagWithoutHash = "travel"
}

struct SmartGView: View {
    // @State private var igHash: String =  "hashtag theme?"
    @State private var textstyle = UIFont.TextStyle.body
    @StateObject var viewModel = SmartGViewModel()
    
    @State private var hashtagEntry: String = Strings.defaultHashtag
    @State private var showingAlert = false
    
    @State private var showingPopover = false
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var hashtags: FetchedResults<Hashtag>
    
    var body: some View {
        ZStack{
            Color.bgFillColor.ignoresSafeArea()
            VStack{
                SmartGHeader()
                collection
                hashtagsList
                interactionBar
            }
        }
        .onAppear {
            viewModel.fetch(hashtag: Strings.defaultHashtagWithoutHash)
        }
    }
}

// Media collection
extension SmartGView {
    var collection: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(alignment: .center, spacing: Constants.collectionInterMediasPadding) {
                // TODO: Find ID error
                let medias = Array(viewModel.dataMedias.enumerated())
                ForEach(medias, id: \.element) { index, media in
                    if let stringUrl = media.media_url,
                       let url = URL(string: stringUrl),
                       !viewModel.computedData.isEmpty,
                       let likeCount = media.like_count,
                       let commentsCount = media.comments_count
                    {
                        let likes = StringFormatter.formatNum(
                            value: Double(likeCount),
                            noDecimal: true)
                        let hashtagsCount = String(viewModel.computedData[index].hashtags.count)
                        StoryCard(
                            url: url,
                            comments: String(commentsCount),
                            likes: likes,
                            hashtagsCount: hashtagsCount)
                        }
                    }
                }
            }
        .padding(.leading)
        .padding(.vertical, Constants.collectionPadding)
    }
}

// Interaction bar
extension SmartGView {
    var interactionBar: some View {
        HStack {
            Button {
                showingPopover = true
            } label: {
                Image(systemName: "list.bullet.circle")
            }
            .popover(isPresented: $showingPopover) {
                List {
                    ForEach(hashtags, id: \.self) {
                        SmartGSavedTagsCell(title: $0.title ?? "Unknown", date: $0.addDate ?? Date())
                    }
                    .onDelete(perform: removeHashtag)
                }
                .font(.headline)
                .padding()
            }
            
            TextField("Enter a hashtag", text: $hashtagEntry)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Spacer()
            
            Button {
                showingAlert = true
                UIPasteboard.general.string = viewModel.topHashtags.joined(separator: " ")
                
            } label: {
                Image(systemName: "paperplane.circle.fill")
            }
            .foregroundColor(.orange)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Top 10 hastags copied!"),
                    message: Text("The most used hashtags of the page \(self.hashtagEntry) were copied into clipboard."),
                    dismissButton: .default(Text("Ok")))
            }
            
            Button {
                let searchedHashtag = self.hashtagEntry.filter { $0 != "#" }
                viewModel.fetch(hashtag: searchedHashtag)
                let entry = self.hashtagEntry
                updateHashtag(entry: entry)
            } label: {
                Image(systemName: "arrow.clockwise.circle.fill")
            }
            .foregroundColor(.green)
        }
        .padding(Constants.interactionBarPadding)
    }
}

// Hashtag list
extension SmartGView {
    var hashtagsList: some View {
        List {
            let topHashatgs = Array(viewModel.topHashtags.enumerated())
            ForEach(topHashatgs, id: \.element){
                index, item in
                    Text("\(String(index+1)): \(item)")
            }
        }
    }
}

// MARK: - Functions
extension SmartGView {
    //AAA - Just a function to print out values
    func printdd (value: Any) -> Bool {
        print(value)
        return true
    }
    
    func updateHashtag (entry: String) {
        if let index = hashtags.firstIndex(where: { $0.title == entry }) {
            moc.delete(hashtags[index])
        }
        saveHashtag(hastagTitle: entry)
    }
    
    func removeHashtag(at offsets: IndexSet) {
        for index in offsets {
            let hashtag = hashtags[index]
            moc.delete(hashtag)
        }
    }
    
    func saveHashtag(hastagTitle: String) {
        let hashtag = Hashtag(context: moc)
        hashtag.id = UUID()
        hashtag.title = "\(hastagTitle)"
        hashtag.addDate = Date()
        try? moc.save()
    }
}

struct SmartGView_Previews: PreviewProvider {
    static var previews: some View {
        SmartGView()
    }
}
