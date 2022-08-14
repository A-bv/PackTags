//
//  SmartGen_SwiftUI.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26/11/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

private enum Strings {
    static let loading3Dots = "Loading...".localized()
    static let smartHashtags = "Smart Hashtags".localized()
    static let hashtagsPageSearch = "Hashtag page search".localized()
}

struct SmartG_SwiftUI: View {
    // @State private var igHash: String =  "hashtag theme?"
    @State private var textstyle = UIFont.TextStyle.body
    @StateObject var viewModel = SmartGViewModel()
    
    @State private var hashtagEntry: String = "#travel"
    @State private var showingAlert = false
    
    var body: some View {
        ZStack{
            Color.bgFillColor.ignoresSafeArea()
            VStack{
                Header()
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(alignment: .center, spacing: 10) {
                        ForEach(Array(viewModel.dataMedias.enumerated()), id: \.element) { index, media in
                        // ForEach(viewModel.dataMedias, id: \.self)
                        //{
                        // media in
                            if let stringUrl = media.media_url, let url = URL(string: stringUrl) {
                                StoryCard(
                                    url: url,
                                    title1: "\(media.comments_count ?? 0)",
                                    title2: StringFormatter.formatNum(
                                        value: Double(media.like_count ?? Int(0.0)),
                                        noDecimal: true),
                                    title3: "\(viewModel.computedData[index].hashtags.count)")
                            }
                        }
                    }
                    
                }
                .padding(.leading)
                .padding(.vertical, 5)
                
                HStack {
                    TextField("Enter a hashtag", text: $hashtagEntry)
                    
                    Button(action: {
                        showingAlert = true
                        print(self.$hashtagEntry)
                    }) {
                        Text("+")
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("Important message"),
                            message: Text("Wear sunscreen"),
                            dismissButton: .default(Text("Ok!")))
                    }
                    
                    Button(action: {
                        
                    }) {
                        Text("Added")
                    }
                    
                    Spacer()
                    Button(action: {
                        print(self.$hashtagEntry)
                    }) {
                        Text("Sync")
                    }
                    .foregroundColor(.green)
                }
                .padding(20)
                
                List {
                    ForEach(Array(viewModel.computedData.enumerated()), id: \.element){
                        index, item in
                        HStack{
                            Text("\(String(index+1)): \(item.hashtags.joined(separator: " "))")
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetch()
        }
    }
    
    //AAA - Just a function to print out values
    func printdd (value: Any) -> Bool {
        print(value)
        return true
    }
}

struct StoryCard: View{
    let url: URL
    let title1: String
    let title2: String
    let title3: String
    
    var body: some View{
        VStack(alignment: .leading){
            //URLImage(urlString: url)
            AsyncImage(
                url: url,
                placeholder: {
                    Text(Strings.loading3Dots)
                },
                image: { Image(uiImage: $0).resizable() })
            .aspectRatio(contentMode: .fill)
            .frame(width: 160, height: 190)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            HStack(){
                if title1 != "0" {
                    Image(systemName: "text.bubble.fill")
                    Text(title1)
                        .font(.system(size: 12, weight: .semibold))
                }
                if title2 != "0" {
                    Image(systemName: "suit.heart.fill")
                    Text(title2)
                        .font(.system(size: 12, weight: .semibold))
                }
                if title3 != "0" {
                    Image(systemName: "number.circle.fill")
                    Text(title3)
                        .font(.system(size: 12, weight: .semibold))
                }
                Spacer()
            }
        }
    }
}

struct Header: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(Strings.smartHashtags)
                    .font(.largeTitle)
                    .foregroundColor(Color(UIColor.label))
                    .fontWeight(.bold)
            
                Text(Strings.hashtagsPageSearch)
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.label))

            }
            Spacer()
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.down.circle")
                    .font(Font.system(.title))
                    .foregroundColor(Color(UIColor.label))
            }
        }
        .padding()
    }
}

struct SmartG_SwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        SmartG_SwiftUI()
    }
}
