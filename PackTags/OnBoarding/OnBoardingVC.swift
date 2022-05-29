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
    @IBOutlet var btnGetStarted: UIButton!

    var scrollWidth: CGFloat! = 0.0
    var scrollHeight: CGFloat! = 0.0

    //data for the slides
    var titles = ["WELCOME TO PACKTAGS","UNIQUE PACKS","ANALYTICS"]
    var descs = ["The smart notebook for your hashtags",
                 "Automatically removes duplicates or invalid hashtags",
                 "Tracks your results for the best strategy"]
    var imgs = ["intro1","intro4","intro5"]
    var btnsHide = [true,true,false]

    //get dynamic width and height of scrollview and save it
    override func viewDidLayoutSubviews() {
        scrollWidth = scrollView.frame.size.width
        scrollHeight = scrollView.frame.size.height
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        //to call viewDidLayoutSubviews() and get dynamic width and height of scrollview
        
        btnGetStarted.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
        btnGetStarted.isHidden = true
        
        

        self.view.backgroundColor = welcomeScreenColor
        self.scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        //crete the slides and add them
        var frame = CGRect(x: 0, y: 0, width: 0, height: 0)

        for index in 0..<titles.count {
            frame.origin.x = scrollWidth * CGFloat(index)
            frame.size = CGSize(width: scrollWidth, height: scrollHeight)

            let slide = UIView(frame: frame)

            //subviews
            let imageView = UIImageView.init(image:
                                                
                                                UIImage.init(named: imgs[index])!
                                                
            )
            
            //Iphone5 adatation
            //under 320: iphones 5, smaller image
            let sW = UIScreen.main.bounds.width
            let dim = sW <= 320 ? 200 : 300
            let fontSize1: CGFloat = sW <= 320 ? 15.0 : 20.0
            //
            
            imageView.frame = CGRect(x:0,y:0,width: dim,height: dim)
            imageView.contentMode = .scaleAspectFit
            imageView.center = CGPoint(x:scrollWidth/2,y: scrollHeight/2 - 50)
          
            let txt1 = UILabel.init(frame: CGRect(x:32,y:imageView.frame.maxY+30,width:scrollWidth-64,height:30))
            txt1.textAlignment = .center
            txt1.font = UIFont.boldSystemFont(ofSize: fontSize1)
            txt1.text = titles[index]

            let txt2 = UILabel.init(frame: CGRect(x:32,y:txt1.frame.maxY+10,width:scrollWidth-64,height:50))
            txt2.textAlignment = .center
            txt2.numberOfLines = 3
            txt2.font = UIFont.systemFont(ofSize: fontSize1 - 2)
            txt2.text = descs[index]

            slide.addSubview(imageView)
            slide.addSubview(txt1)
            slide.addSubview(txt2)
            scrollView.addSubview(slide)
            
        }

        //set width of scrollview to accomodate all the slides
        scrollView.contentSize = CGSize(width: scrollWidth * CGFloat(titles.count), height: scrollHeight)

        //disable vertical scroll/bounce
        self.scrollView.contentSize.height = 1.0

        //initial state
        pageControl.numberOfPages = titles.count
        pageControl.currentPage = 0

    }

    //indicator
    @IBAction func pageChanged(_ sender: Any) {
        scrollView!.scrollRectToVisible(CGRect(x: scrollWidth * CGFloat ((pageControl?.currentPage)!), y: 0, width: scrollWidth, height: scrollHeight), animated: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setIndiactorForCurrentPage()
    }

    func setIndiactorForCurrentPage()  {
        let page = (scrollView?.contentOffset.x)!/scrollWidth
        pageControl?.currentPage = Int(page)
        
        if Int(page) == 2 {
            btnGetStarted.isHidden = false
        } else {
            btnGetStarted.isHidden = true
        }
         

    }
    
    @objc func didTap(_ sender: UIButton) {
        Core.shared.setIsNotNewUser()
        self.dismiss(animated: true)
        
        showTipsAlert()

    }
    
}


class Core {
    
    static let shared = Core()
    
    func isNewUser () -> Bool {
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setIsNotNewUser () {
        UserDefaults.standard.setValue(true, forKey: "isNewUser")
    }
    
}

extension UIViewController {
    func showOnboardingScreen() {
        
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "welcome") as! OnBoardingController
           
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
            
        
    }
}


