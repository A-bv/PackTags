//
//  PackTVC+Cell.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 10/03/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension PackTableVC {
    func willAppear() {
        navigationController?.navigationBar.largeTitleTextAttributes = viewModel.getNavigationBarStyleAttributes (isWhite: true)
    }
    
    func willDisappear() {
        navigationController?.navigationBar.largeTitleTextAttributes = viewModel.getNavigationBarStyleAttributes (isWhite: false)
    }
}
