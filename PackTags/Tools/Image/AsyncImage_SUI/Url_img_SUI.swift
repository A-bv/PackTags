//
//  UrlImageSwiftUI.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15/12/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

struct URLImage: View {
    let urlString: String
    @State var data: Data?
    
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .resizable()
                .background(Color.gray)
                .frame(width: 130, height: 150)
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
        } else {
            Image(systemName: "photo.circle.fill")
                //.resizable()
                .font(.system(size: 50, weight: .ultraLight))
                
                .frame(width: 130, height: 150)
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .onAppear{
                    fetchData()
                }
        }
    }
    
    private func fetchData() {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _,_ in
            self.data = data
        }
        task.resume()
    }
}
