//
//  AnalyticsView.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 18.11.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//
//Display the rigth VC according to iOS version

import UIKit
import SwiftUI

class AnalyticsViewController: UIViewController {
    
    deinit {
        print("deinit AnalyticsVC")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view under blur adjustment
        self.view.backgroundColor = UIColor.morphicWhite.withAlphaComponent(0.70)
        
        self.add(UIHostingController(rootView: AnyView(AnalyticsNew())))
    }
}

extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        child.view.frame = view.bounds
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else {return}
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
