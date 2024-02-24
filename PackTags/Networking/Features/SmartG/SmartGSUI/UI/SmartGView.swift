//
//  SmartGen_SwiftUI.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26/11/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

private enum Strings {
    static let defaultHashtag = ""
    static let defaultHashtagWithoutHash = "travel"
}

struct SmartGView: View {
    // @State private var igHash: String =  "hashtag theme?"
    @State private var textstyle = UIFont.TextStyle.body
    @StateObject var smartGViewModel = SmartGViewModel()
    
    @State var hashtagEntry: String = Strings.defaultHashtag
    @State var showingAlert = false
    
    @State var showingPopover = false
    @State var loading = true
    
    //Network Status
    @ObservedObject var monitor = NetworkMonitor()
    
    var body: some View {
        ZStack{
            Color.bgFillColor.ignoresSafeArea()
            if !monitor.isConnected {
                OfflineView()
            } else if loading {
                LoadingView(loading: $loading).opacity(0.5)
            } else {
                ScrollView{
                    SmartGHeader()
                    interactionBar
                    FloatingListView(viewModel: self.smartGViewModel)
                    collection
                }
                .ignoresSafeArea(.keyboard)
            }
        }
        .onAppear {
            loading = true
            smartGViewModel.fetch(
                hashtag: Strings.defaultHashtagWithoutHash,
                onLoaded: {
                    loading = false
                })
        }
    }
    
    var interactionBar: some View {
        InteractionBarView(
            loading: $loading,
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
