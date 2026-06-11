//https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift

import UIKit
// Downsampling UIKIT
extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            let hScale = newSize.height / size.height
            let vScale = newSize.width / size.width
            let scale = max(hScale, vScale) // scaleToFill
            let resizeSize = CGSize(width: size.width*scale, height: size.height*scale)
            var middle = CGPoint.zero
            if resizeSize.width > newSize.width {
                middle.x -= (resizeSize.width-newSize.width)/2.0
            }
            if resizeSize.height > newSize.height {
                middle.y -= (resizeSize.height-newSize.height)/2.0
            }
            
            draw(in: CGRect(origin: middle, size: resizeSize))
        }
    }
}

// Avoid upside down image
extension UIImage {
    func upOrientationImage() -> UIImage? {
        switch imageOrientation {
        case .up:
            return self
        default:
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            draw(in: CGRect(origin: .zero, size: size))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result
        }
    }
}

// Add a filter
extension UIImageView {
    func putFilter ()
    {
        guard let img = self.image else { return }
        let beginImage = CIImage(image: img)
        let edgeDetectFilter = CIFilter(name: "CIVignetteEffect")!
        edgeDetectFilter.setValue(beginImage, forKey: kCIInputImageKey)
        edgeDetectFilter.setValue(0.12, forKey: "inputIntensity")
        edgeDetectFilter.setValue(0.2, forKey: "inputRadius")
    
        guard let ciImage = edgeDetectFilter.outputImage else { return }
                
        let newImage = UIImage(ciImage: ciImage)
        self.image = newImage
    }
}

// Bounce effect
extension UIImageView {
    func bounceImage(offset: CGFloat, constant: CGFloat) {
        let offsetToBounceFrom = -UIScreen.main.bounds.height/2
        
        if offset < offsetToBounceFrom {
            self.frame.size.height = -offset + constant
        } else {
            self.frame.size.height = self.frame.height
        }
    }
}
