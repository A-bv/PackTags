//
//  RateAndReview.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26/08/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//
import UIKit

extension UIViewController {
    private enum Strings {
        static let rateAndReviewYourFeedback = "Your feedback".localized()
        static let rateAndReviewEnjoyingQuestion = "Are you enjoying PackTags?".localized()
        static let rateAndReviewDismiss = "Dismiss".localized()
        static let rateAndReviewRateUsOnAppStore = "Yes! Rate us on the App Store.".localized()
        static let rateAndReviewTellUsWhyQuestion = "No! Tell us why.".localized()
    }
    
    private enum Links {
        static let packTagsAppStoreUrl = "https://apps.apple.com/app/id1579377025"
    }
    
    func showReviewPopUp () {
        let alert = UIAlertController(
            title: Strings.rateAndReviewYourFeedback,
            message: Strings.rateAndReviewEnjoyingQuestion,
            preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(
                title: Strings.rateAndReviewDismiss,
                style: .cancel,
                handler: nil))
        
        alert.addAction(
            UIAlertAction(
                title: Strings.rateAndReviewRateUsOnAppStore,
                style: .default, handler: {  [weak self] _ in
            self?.writeReview ()
        }))
        
        alert.addAction(
            UIAlertAction(
                title: Strings.rateAndReviewTellUsWhyQuestion,
                style: .default, handler: {  [weak self] _ in
            self?.sendEmail()
        }))
        
        present(alert, animated: true)
    }
    
    func shareApp () {
        guard let productURL = URL(
            string: Links.packTagsAppStoreUrl) else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: [productURL],
            applicationActivities: nil)
        
        //For iPad, popover
        if UIDevice.current.userInterfaceIdiom == .pad {
            let pvr = activityViewController
            pvr.popoverPresentationController?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
            pvr.popoverPresentationController?.sourceView = view
            pvr.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        
        present(activityViewController, animated: true, completion: nil)
        
    }
    
    func writeReview () {
        guard let productURL = URL(
            string: Links.packTagsAppStoreUrl) else { return }
        var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)
        
        components?.queryItems = [
          URLQueryItem(name: "action", value: "write-review")
        ]

        guard let writeReviewURL = components?.url else {
          return
        }
        
        UIApplication.shared.open(writeReviewURL)
    }
}
