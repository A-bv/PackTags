//
//  PdfVC.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 16/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import PDFKit
import WebKit

var currentPDF = ""

class PdfVC: UIViewController {
    
    deinit {
        print("deinit")
    }
    
    let acceptBtn: UIButton = {
        let button = UIButton.init()
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Accept", for: .normal)
        button.backgroundColor = bkgdColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(acceptPDF(_:)), for: .touchUpInside)
        return button
    }()
    
    @objc func acceptPDF (_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            addPDF ()
        } else {
            addPDFOldV ()
        }
        
    }
    
    @available(iOS 11.0, *)
    func addPDF () {
        let name = currentPDF
        
        let pdfView = PDFView()
        
        
        
        //Constraints
        
        //pdf
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        //button
        view.addSubview(acceptBtn)
        acceptBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        acceptBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        acceptBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        acceptBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        //mask transparent area below button at bottom:
        let maskbottom = UIView()
        maskbottom.backgroundColor = bkgdColor
        maskbottom.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(maskbottom)
        maskbottom.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        maskbottom.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        maskbottom.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        maskbottom.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        
        //Pdf
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        guard let path = Bundle.main.url(forResource: name, withExtension: "pdf") else { return }
        
        let document = PDFDocument(url: path)
        pdfView.document = document
        
        pdfView.subviews[0].backgroundColor = bkgdColor
    }
    
    func addPDFOldV () {
        
        let webView = WKWebView()
        
        let btnHeight = CGFloat(60)
        
        webView.contentMode = .scaleToFill
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        //button
        view.addSubview(acceptBtn)
        acceptBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        acceptBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        acceptBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        acceptBtn.heightAnchor.constraint(equalToConstant: btnHeight).isActive = true
        
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIApplication.shared.statusBarFrame.height).isActive = true
        webView.bottomAnchor.constraint(equalTo: acceptBtn.topAnchor).isActive = true
        
        webView.subviews[0].backgroundColor = bkgdColor
        
        guard let targetURL = Bundle.main.url(forResource: currentPDF, withExtension: "pdf") else {
            return
        }
        let request = NSURLRequest(url: targetURL)
        webView.load(request as URLRequest)

    
    }
    
}
