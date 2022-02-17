//
//  SmartGen_SwiftUI.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26/11/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

#if !arch(arm)
import SwiftUI

@available(iOS 14.0.0, *)
struct SmartG_SwiftUI: View {
    @State private var igHash: String =  "top travel hashtags"
    @State private var textstyle = UIFont.TextStyle.body
    @StateObject var viewModel = SmartGViewModel()
    
    var body: some View {
        ZStack{
            Color.bgFillColor.ignoresSafeArea()
            VStack{
                Header()
                ScrollView(.horizontal, showsIndicators: false){
                    HStack {
                        ForEach(viewModel.dataMedias, id: \.self){
                        media in
                            if let stringUrl = media.media_url, let url = URL(string: stringUrl) {
                                StoryCard(url: url, title: "\(media.comments_count ?? 0)")
                            }
                        }
                    }
                }
                .padding(.leading)
                .padding(.vertical, 5)
                List {
                    ForEach(viewModel.computedData, id: \.self){
                        item in
                        HStack{
                            Text("1")
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetch()
        }
    }
}

@available(iOS 14.0.0, *)
struct StoryCard: View{
    
    let url: URL
    let title: String
    
    var body: some View{
        VStack(alignment: .leading){
            //URLImage(urlString: url)
            AsyncImage(
                url: url,
                placeholder: { Text("Loading ...") },
                image: { Image(uiImage: $0).resizable() }
            )
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 160, height: 190)
                
                .clipShape(RoundedRectangle(cornerRadius: 15))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
        }
    }
}

@available(iOS 14.0.0, *)
struct Header: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                
                Text("Smart hashtags")
                    .font(.largeTitle)
                    .foregroundColor(Color(UIColor.label))
                    .fontWeight(.bold)
            
                Text("Hashtag page search")
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

@available(iOS 14.0.0, *)
struct SmartG_SwiftUI_Previews: PreviewProvider {
    
    static var previews: some View {
        SmartG_SwiftUI()
    }
}
#endif








