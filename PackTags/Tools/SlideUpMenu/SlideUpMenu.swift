//
//  SlideUpMenu.swift
//  SlideUpAnimation
//
//  Created by Alexandre Bevilacqua on 28.05.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

struct SlideUpMenuConstants {
    static let cellHeight: CGFloat = 50
    static let tableHeight: CGFloat = 314
    static let tablePadding: CGFloat = 32
}

protocol SlideUpMenuDelegate {
    func tableRowDidSelect(_ indexPath: IndexPath)
}

class SlideUpMenu: NSObject {
    var presenter: UIViewController?
    var menuController = SlideUpMenuViewController()
    var MenuButton: UIBarButtonItem!
    
    init(controller: UIViewController?) {
        super.init()
        presenter = controller
        MenuButton = UIBarButtonItem(
            image: UIImage(named: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(onClickMenu))
    }
    
    @objc func onClickMenu() {
        menuController.modalPresentationStyle = .custom
        menuController.transitioningDelegate = self
        menuController.delegate = presenter as? SlideUpMenuDelegate
        presenter?.present(menuController, animated: true, completion: nil)
    }
}

extension SlideUpMenu: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
