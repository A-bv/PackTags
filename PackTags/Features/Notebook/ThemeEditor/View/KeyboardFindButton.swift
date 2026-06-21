import UIKit

/// A magnifier button that floats above the keyboard — visible only while
/// the keyboard is up — and presents the system find panel
/// (`UIFindInteraction`, the Notes-style search bar) for the attached
/// text view.
final class KeyboardFindButton: UIButton {

    private weak var textView: UITextView?

    init() {
        super.init(frame: .zero)
        configuration = .gray()
        configuration?.image = UIImage(systemName: "magnifyingglass")
        configuration?.cornerStyle = .capsule
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        accessibilityLabel = "Search".localized()
        addAction(UIAction { [weak self] _ in self?.presentSearch() }, for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Enables the system find interaction on `textView` and pins the
    /// button above the keyboard in `host`.
    func attach(to textView: UITextView, in host: UIView) {
        self.textView = textView
        textView.isFindInteractionEnabled = true
        host.addSubview(self)
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: host.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            bottomAnchor.constraint(equalTo: host.keyboardLayoutGuide.topAnchor, constant: -8),
        ])
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardDidShow),
            name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func presentSearch() {
        isHidden = true
        textView?.findInteraction?.presentFindNavigator(showingReplace: false)
    }

    @objc private func keyboardDidShow() {
        isHidden = textView?.findInteraction?.isFindNavigatorVisible == true
    }

    @objc private func keyboardWillHide() {
        isHidden = true
    }
}
