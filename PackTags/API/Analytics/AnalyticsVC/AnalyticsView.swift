//
//  AnalyticsView.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 18.11.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//
//Display the rigth VC according to iOS version


#if canImport(SwiftUI)
import SwiftUI
#endif
import UIKit

class AnalyticsView: UIViewController {
    
    deinit {
        print("deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view under blur adjustment
        self.view.backgroundColor = UIColor.morphicWhite.withAlphaComponent(0.70)
        
        self.add(createViewController())
        
    }
    
    func createViewController() -> UIViewController {
        if #available(iOS 14, *) {
            #if !arch(arm) //compatible SwiftUI IOS <10
            let VC = AnalyticsNew()
            let host = UIHostingController(rootView: AnyView(VC))
            return host
            #else
            return AnalyticsOld()
            #endif
        } else {
            return AnalyticsOld()
        }
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
