//
//  TVC+Navigation.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 28.05.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension ThemeEditorViewController {
    @objc func cancel() {
        if presentingViewController is UINavigationController {
            dismiss(animated: true) { [weak self] in
                self?.onCancel?()
            }
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: false)
            onCancel?()
        } else {
            dismiss(animated: true) { [weak self] in
                self?.onCancel?()
            }
        }
    }
}
