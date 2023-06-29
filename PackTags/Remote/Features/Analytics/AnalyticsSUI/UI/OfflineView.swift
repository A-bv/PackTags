//
//  File.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 29.06.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

struct OfflineView: View {
    private enum Constants {
        static let offlineViewFontSize: CGFloat = 56
    }
    
    private enum Strings {
        static let notConnected = "Not connected".localized()
    }
    
    var body: some View {
        ZStack {
            Color.bgFillColor
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image(systemName: "wifi.slash")
                    .font(.system(size: Constants.offlineViewFontSize))
                Text(Strings.notConnected)
            }
        }
    }
}

struct OfflineView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineView()
    }
}
