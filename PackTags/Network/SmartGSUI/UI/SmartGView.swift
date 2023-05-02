//
//  SmartGen_SwiftUI.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26/11/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

private enum Strings {
    static let defaultHashtag = "#travel"
    static let defaultHashtagWithoutHash = "travel"
}

struct SmartGView: View {
    // @State private var igHash: String =  "hashtag theme?"
    @State private var textstyle = UIFont.TextStyle.body
    @StateObject var smartGViewModel = SmartGViewModel()
    
    @State var hashtagEntry: String = Strings.defaultHashtag
    @State var showingAlert = false
    
    @State var showingPopover = false
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var hashtags: FetchedResults<Hashtag>
    
    var body: some View {
        ZStack{
            Color.bgFillColor.ignoresSafeArea()
            VStack{
                SmartGHeader()
                collection
                FloatingListView()
                interactionBar
            }
        }
        .onAppear {
            smartGViewModel.fetch(hashtag: Strings.defaultHashtagWithoutHash)
        }
    }
}

struct SmartGView_Previews: PreviewProvider {
    static var previews: some View {
        SmartGView()
    }
}
