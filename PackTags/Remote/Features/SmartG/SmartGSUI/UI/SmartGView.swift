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
    
    var body: some View {
        ZStack{
            Color.bgFillColor.ignoresSafeArea()
            ScrollView{
                SmartGHeader()
                interactionBar
                FloatingListView(viewModel: self.smartGViewModel)
                collection
            }
            .ignoresSafeArea(.keyboard)
        }
        .onAppear {
            smartGViewModel.fetch(hashtag: Strings.defaultHashtagWithoutHash)
        }
    }
    
    var interactionBar: some View {
        InteractionBarView(
            showingPopover: $showingPopover,
            hashtagEntry: $hashtagEntry,
            showingAlert: $showingAlert,
            smartGViewModel: smartGViewModel)
    }
}

struct SmartGView_Previews: PreviewProvider {
    static var previews: some View {
        SmartGView()
    }
}
