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
    @StateObject var smartGViewModel: SmartGViewModel
    
    @State var hashtagEntry: String = Strings.defaultHashtag
    @State var showingAlert = false
    
    @State var showingPopover = false
    @State var loading = true
    @State var isErrorState = false
    
    //Network Status
    @StateObject var monitor = NetworkMonitor()

    init(hashtagProvider: any HashtagSearchProviding = UnavailableHashtagProvider()) {
        _smartGViewModel = StateObject(
            wrappedValue: SmartGViewModel(hashtagProvider: hashtagProvider))
    }
    
    var body: some View {
        ZStack{
            Color.bgFillColor.ignoresSafeArea()
            if !monitor.isConnected {
                OfflineView()
            } else {
                VStack() {
                    SmartGHeader()
                    interactionBar
                    Spacer()
                    if loading {
                        LoadingView(loading: $loading).opacity(0.8)
                    } else if isErrorState {
                        SmartGErrorStateView()
                    } else {
                        ScrollView{
                            VStack {
                                FloatingListView(viewModel: self.smartGViewModel)
                                collection
                                    .padding(.vertical)
                            }
                        }
                        .ignoresSafeArea(.keyboard)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            loading = true
            smartGViewModel.fetch(
                hashtag: Strings.defaultHashtagWithoutHash,
                onLoaded: { state in
                    isErrorState = state
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
            isErrorState: $isErrorState,
            smartGViewModel: smartGViewModel)
    }
}

struct SmartGView_Previews: PreviewProvider {
    static var previews: some View {
        SmartGView()
    }
}
