//
//  SmartGInteractionBar.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 01.05.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

struct InteractionBarView: View {
    @Binding var showingPopover: Bool
    @Binding var hashtagEntry: String
    @Binding var showingAlert: Bool
    @Environment(\.managedObjectContext) var moc
    
    var hashtags: FetchedResults<Hashtag>
    var smartGViewModel: SmartGViewModel
    private enum Constants {
        static let interactionBarPadding: CGFloat = 10
    }
    
    private enum Strings {
        static let popoverTitle = "Top 10 hashtags copied!"
        static func popoverMessage(for hashtagEntry: String) -> String {
            "The most used hashtags of the page \(hashtagEntry) were copied into the clipboard."
        }
        static let popoverDismissButton = "Ok"
        static let enterHashtagPlaceholder = "Enter a hashtag"
        static let unknownHashtagTitle = "Unknown"
    }
    
    var body: some View {
        HStack {
            TextField(Strings.enterHashtagPlaceholder, text: $hashtagEntry)
                .padding()
            
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
                    message: Text(Strings.popoverMessage(for: hashtagEntry)),
                    dismissButton: .default(Text(Strings.popoverDismissButton)))
            }
            
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .soft)
                impactMed.impactOccurred()
                let searchedHashtag = hashtagEntry.filter { $0 != "#" }
                smartGViewModel.fetch(hashtag: searchedHashtag)
                updateHashtag(entry: hashtagEntry)
            } label: {
                Image(systemName: "arrow.clockwise.circle")
                    .foregroundColor(Color("Color4"))
            }
            .buttonStyle(ColorfulButtonStyle())
            
            Button {
                showingPopover = true
            } label: {
                Image(systemName: "info.circle")
                    .foregroundColor(Color("Color4"))
            }
            .buttonStyle(ColorfulButtonStyle())
            .popover(isPresented: $showingPopover) {
                VStack {
                    Text("Hashtags")
                        .font(.headline)
                        .padding()
                    
                    List {
                        ForEach(hashtags, id: \.self) { hashtag in
                            SmartGSavedTagsCell(title: hashtag.title ?? Strings.unknownHashtagTitle, date: hashtag.addDate ?? Date())
                        }
                        .onDelete(perform: removeHashtag)
                    }
                    .font(.body)
                    .padding()
                }
            }
        }
        .padding(Constants.interactionBarPadding)
    }
}

struct InteractionBarView_Previews: PreviewProvider {
    static var previews: some View {
        @FetchRequest(sortDescriptors: []) var hashtags: FetchedResults<Hashtag>
        
        return InteractionBarView(
            showingPopover: .constant(false),
            hashtagEntry: .constant(""),
            showingAlert: .constant(false),
            hashtags: hashtags,
            smartGViewModel: SmartGViewModel())
        .padding()
    }
}

/*
Button(
 action: {
    let impactMed = UIImpactFeedbackGenerator(style: .soft)
    impactMed.impactOccurred()

}) {
    Image(systemName: "scale.3d")
        .foregroundColor(Color("Color4"))
}
.buttonStyle(ColorfulButtonStyle())
*/

