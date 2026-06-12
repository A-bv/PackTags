import UIKit

extension UITextView {
    func notHiddenByKeyboard() {
        setupKeyboardNotifications()
    }
    
    private func setupKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func adjustForKeyboard(notification: Notification)
    {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {return}
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        // let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let keyboardViewEndFrame = keyboardScreenEndFrame
        if notification.name == UIResponder.keyboardWillHideNotification {
            self.contentInset = .zero
        } else {
            self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        //scrollBar size
        self.scrollIndicatorInsets = self.contentInset
    }
}
