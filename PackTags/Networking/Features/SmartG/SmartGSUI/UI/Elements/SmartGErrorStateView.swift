//
//  SmartGErrorStateView.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 25.02.2024.
//  Copyright © 2024 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

struct SmartGErrorStateView: View {    
    private enum Strings {
        static let errorState = "Oups! Could not find hashtags.\nCheck your entry.".localized()
    }
    
    private enum Constants {
        static let imageViewSize: CGFloat = 250
        static let interPadding: CGFloat = 30
        static let illustrationShadow: CGFloat = 0.8
    }
    
    var body: some View {
        
        VStack(spacing: Constants.interPadding) {
            Image(uiImage: UIImage(named: "SearchingIllustration")!)
                .resizable()
                .scaledToFit()
                .frame(
                    width: Constants.imageViewSize,
                    height: Constants.imageViewSize)
                .shadow(radius: Constants.illustrationShadow)
            Text(Strings.errorState)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

struct SmartGErrorStateView_Previews: PreviewProvider {
    static var previews: some View {
        SmartGErrorStateView()
    }
}

