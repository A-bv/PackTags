//
//  OnBoardingVC.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class OnBoardingController: UIViewController, UIScrollViewDelegate {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var getStartedBtn: UIButton!

    var scrollWidth: CGFloat! = 0.0
    var scrollHeight: CGFloat! = 0.0
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)

    private enum Strings {
        static let onBoardingPageTitle1  = "WELCOME TO PACKTAGS".localized()
        static let onBoardingPageTitle2  = "UNIQUE PACKS".localized()
        static let onBoardingPageTitle3  = "ANALYTICS".localized()
        static let onBoardingPageSubtitle1  = "The smart notebook for your hashtags".localized()
        static let onBoardingPageSubtitle2  = "Automatically removes duplicates or invalid hashtags".localized()
        static let onBoardingPageSubtitle3  = "Tracks your results for the best strategy".localized()
    }

    private enum Constants {
        static let subtitleNumberOfLines = 3
        static let spacing10 = CGFloat(10)
        static let spacing30 = CGFloat(30)
        static let titleHeight = CGFloat(30)
        static let labelsXPadding = CGFloat(32)
        static let imageViewCenterPositionYAdjustment = -CGFloat(50)
        static let subtitleHeight = CGFloat(50)
        static let scrollWidthPadding = CGFloat(64)
        static let screenWidth = UIScreen.main.bounds.width
        static let disableVerticalScrollOrBounceValue = CGFloat(1)
        
        static let smallScreenWidthLimit = CGFloat(320)
        static let adaptativeImageViewLenght = screenWidth <= smallScreenWidthLimit ? 200 : 300
        static let fontSize1: CGFloat = screenWidth <= smallScreenWidthLimit ? 15.0 : 20.0
        static let fontSize2: CGFloat = fontSize1 - 2
    }

    var titles = [
        Strings.onBoardingPageTitle1,
        Strings.onBoardingPageTitle2,
        Strings.onBoardingPageTitle3
    ]

    var captions = [
        Strings.onBoardingPageSubtitle1,
        Strings.onBoardingPageSubtitle2,
        Strings.onBoardingPageSubtitle3
    ]

    var illustrations = [
        "intro1",
        "intro4",
        "intro5"
    ]

    override func viewDidLayoutSubviews() {
        scrollWidth = scrollView.frame.size.width
        scrollHeight = scrollView.frame.size.height
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded() // used to call viewDidLayoutSubviews()
        self.view.backgroundColor = welcomeScreenColor

        setupGetStartedButton ()
        setupScrollView()
        setupSlides()
        initializePageControl()
    }

    private func setupSlides() {
        for index in 0..<titles.count {
            let slide = makeSlide(index: index)
            addSlideToScrollView(slide: slide)
        }
    }

    private func setupGetStartedButton () {
        getStartedBtn.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
        getStartedBtn.isHidden = true
    }

    private func initializePageControl() {
        pageControl.numberOfPages = titles.count
        pageControl.currentPage = 0
    }

    private func setupScrollView() {
        self.scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }

    private func makeSlide (index: Int) -> UIView {
        let imageViewFrame = CGRect(
            x: 0,
            y: 0,
            width: Constants.adaptativeImageViewLenght,
            height: Constants.adaptativeImageViewLenght)
        let imageViewCenter = CGPoint(
            x: scrollWidth/2,
            y: scrollHeight/2 + Constants.imageViewCenterPositionYAdjustment)
        
        let imageView = UIImageView.init(image:  UIImage.init(named: illustrations[index])!)
        imageView.frame = imageViewFrame
        imageView.contentMode = .scaleAspectFit
        imageView.center = imageViewCenter
        
        let titleFrame = CGRect(
            x: Constants.labelsXPadding,
            y: imageView.frame.maxY + Constants.spacing30,
            width: scrollWidth - Constants.scrollWidthPadding,
            height: Constants.titleHeight)
        let title = UILabel.init(frame: titleFrame)
        title.textAlignment = .center
        title.font = UIFont.boldSystemFont(ofSize: Constants.fontSize1)
        title.text = titles[index]

        let subtitleFrame = CGRect(
            x: Constants.labelsXPadding,
            y: title.frame.maxY + Constants.spacing10,
            width: scrollWidth - Constants.scrollWidthPadding,
            height: Constants.subtitleHeight)
        let subtitle = UILabel.init(frame: subtitleFrame)
        subtitle.textAlignment = .center
        subtitle.font = UIFont.systemFont(ofSize: Constants.fontSize2)
        subtitle.text = captions[index]
        subtitle.numberOfLines = Constants.subtitleNumberOfLines

        frame.origin.x = scrollWidth * CGFloat(index)
        frame.size = CGSize(
            width: scrollWidth,
            height: scrollHeight)

        let slide = UIView(frame: frame)
        slide.addSubview(imageView)
        slide.addSubview(subtitle)
        slide.addSubview(title)

        return slide
    }

    private func addSlideToScrollView (slide: UIView) {
        let scrollviewWidthToAccomodateAllSlides = scrollWidth * CGFloat(titles.count)
        scrollView.contentSize = CGSize(
            width: scrollviewWidthToAccomodateAllSlides,
            height: scrollHeight)
        scrollView.contentSize.height = Constants.disableVerticalScrollOrBounceValue
        scrollView.addSubview(slide)
    }
}

extension OnBoardingController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setIndiactorForCurrentPage()
    }

    func setIndiactorForCurrentPage()  {
        let page = (scrollView?.contentOffset.x)!/scrollWidth
        pageControl?.currentPage = Int(page)
        getStartedBtn.isHidden = Int(page) != titles.count - 1
    }
    
    @IBAction func pageChanged(_ sender: Any) {
        let currentPage = CGFloat((pageControl?.currentPage)!)
        let pageControlFrame = CGRect(
            x: scrollWidth * currentPage,
            y: 0,
            width: scrollWidth,
            height: scrollHeight)
        scrollView!.scrollRectToVisible(pageControlFrame,animated: true)
    }

    @objc func didTap(_ sender: UIButton) {
        Core.shared.setIsNotNewUser()
        if shouldShowTipsAlert() {
            Alerts.showFirstTimeTipsAlert(presentingVc: self)
        }
        dismiss(animated: true)
    }
    
    private func shouldShowTipsAlert() -> Bool {
        let tipsAlertShown = UserDefaults.standard.bool(forKey: "showTipsAlertShown")
        if !tipsAlertShown {
            UserDefaults.standard.set(true, forKey: "showTipsAlertShown")
        }
        return !tipsAlertShown
    }
}

extension UIViewController {
    func showOnboardingScreen() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "welcome") as! OnBoardingController
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}
