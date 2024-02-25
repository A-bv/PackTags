//
//  File.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 25.02.2024.
//  Copyright © 2024 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import SwiftUI

class SmartGHostingViewController: UIViewController {
    deinit {
        print("deinit SmartGHostingVC")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.add(UIHostingController(rootView: AnyView(SmartGViewContainer())))
    }

    private func add(_ child: UIViewController) {
        addChild(child)
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        child.view.frame = view.bounds
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
}
