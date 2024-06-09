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
        showView()
    }
    
    private func showView() {
        let isCorrectSetup = UserDefaults.standard.bool(forKey: "isCorrectSetup")
        if isCorrectSetup {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let dataController = appDelegate.dataController
            let hostingController = UIHostingController(rootView: SmartGViewContainer(dataController: dataController))
            add(hostingController)
        } else {
            showFBLoginScreenFromThemeVC()
        }
    }

    private func add(_ child: UIViewController) {
        addChild(child)
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        child.view.frame = view.bounds
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    private func showFBLoginScreenFromThemeVC() {
        let viewModel = FBLoginViewModel()
        let viewController = FBLoginVC(viewModel: viewModel)
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .coverVertical
        self.present(viewController, animated: true, completion: nil)
    }
}
