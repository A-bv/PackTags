//
//  AnalyticsUIKit.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 08.01.21.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class AnalyticsOld: UIViewController {
    
    deinit {
        print("deinit")
    }
    
    let infoTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear //morphicWhite
        textView.translatesAutoresizingMaskIntoConstraints = false //enable autolayout
        return textView
    }()
    
    let loginSpinner: UIActivityIndicatorView = {
        let loginSpinner = UIActivityIndicatorView(style: .gray)
        loginSpinner.translatesAutoresizingMaskIntoConstraints = false
        loginSpinner.hidesWhenStopped = true
        return loginSpinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI
        self.view.applyBlur()
        self.modalUI(arrowButton: true)
        addSpinner(spinner: loginSpinner)
        placeTextView(textView: infoTextView)
        view.backgroundColor = UIColor.clear //morphicWhite
        
        //Load data for AnalyticsOld (AnalyticsOld's func list)
        if GetJson.canRefresh() == true {
            //getOnlineJsonApiGraphOld()
        } else {
            getJsonFromDir()
        }
        //YYY getOnlineJson()
    }
}





//MARK: Operations
extension AnalyticsOld {
    /* YYY
    func displayData (Json: Profile) {
        let top = Json.graphql?.user
        let data = ProcessJson.processJSON(decodedJson: Json)
        
        if top?.is_private == true {
            self.infoTextView.text = "account is private"
        } else if top?.is_private == false {
            let st = (data.rates.count == 1) ? "" : "on the last \(data.rates.count) posts"
            self.infoTextView.text = """
            Username: \(top?.username ?? "nil")\n
            \(top?.biography ?? "nil")\n
            Followers: \(top?.edge_followed_by?.count ?? 0)\n
            Following: \(top?.edge_follow?.count ?? 0)\n
            Number of posts: \(top?.edge_owner_to_timeline_media?.count ?? 0)\n
            Total number of likes \(st): \(data.sum0 ?? 0)\n
            Total number of comments \(st): \(data.sum1 ?? 0)\n
            Average engagement \(st): \( String(format: "%.2f",data.avg2 ?? 0)) %\n
            """
        } else {
            self.infoTextView.text = "no accound was found with this username"
        }
        //print(data)
    }*/

    func displayDataComingFromApiGraph (Json: Profile) {
        guard let data = ProcessJson.processJsApiGraph(decodedJson: Json) else { return }
        
        if data.usr != nil {
            let st = (data.rates.count == 1) ? "": "Last \(data.rates.count) Posts "
            let st2 = (data.rates.count == 1) ? "" : "Average "
            
            var aEngRates = [data.avg2]
            
            for i in 1...2 {
                mode = i
                aEngRates.append(data.avg2)
            }
            mode = 0
            
            //Followers formatting
            let numFws = Double(Json.followers_count ?? 0)
            let fmtFws = ProcessJson.formatNum(value: numFws)
            let fws = numFws < 100 ? fmtFws.components(separatedBy: ".")[0]  : fmtFws
            
            self.infoTextView.text = """
            👤 \(Json.username ?? "No Account Found")\n
            Followers: \(fws)\n
            
            📊 Total Number of*:
            
            Likes: \(data.sum0 ?? 0)
            Comments: \(data.sum1 ?? 0)
            
            
            📊 \(st2)Insigths*:\n
            Engagement: \( ProcessJson.formatNum(value: Double(aEngRates[0] ?? 0)) )
            Reach: \( ProcessJson.formatNum(value: Double(aEngRates[1] ?? 0)) )
            Impressions: \( ProcessJson.formatNum(value: Double(aEngRates[2] ?? 0)) )\n
            
            
            *\(st)
            """
            
        } else {
            self.infoTextView.text = "\n\n\n\n\n\nData unavailable\n\nOr\n\nLikely no new posts\nas a Business/Creator account"
        }
    }
}


//MARK: - Layout
extension UIViewController {
    func addSpinner(spinner:UIActivityIndicatorView) {
        self.view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
}
