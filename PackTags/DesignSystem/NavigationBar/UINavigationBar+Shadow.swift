import UIKit

extension UINavigationBar {
    func putShadow (_ put:Bool = true) {
        
        let nbl = self.layer
        nbl.shadowOffset = CGSize(width: 5, height: 5)
        nbl.shadowColor = UIColor.shadowColor.cgColor
        
        if put {
            nbl.shadowRadius = 5
            nbl.shadowOpacity = 0.4 //0.35
        } else {
            nbl.shadowRadius = 0
            nbl.shadowOpacity = 0.0
        }
    }
}
