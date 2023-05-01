//
//  SmartGInteractionBar.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 01.05.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

private enum Constants {
    static let interactionBarPadding: CGFloat = 20
}

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
