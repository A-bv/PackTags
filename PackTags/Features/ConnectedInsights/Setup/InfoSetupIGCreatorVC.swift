import UIKit

class InfoSetupIGCreatorVC: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Constants

    private enum Constants {
        static let openInstagramBtnHeight: CGFloat = 44
        static let openInstagramBtnBottomPadding: CGFloat = -50
        static let labelHeight: CGFloat = 44.0
        static let textViewWidth: CGFloat = 300
        static let textViewHeight: CGFloat = 150
        static let iconBounds = CGRect(x: 0, y: -5, width: 30, height: 30)
        static let stackViewSpacing: CGFloat = 50
    }

    // MARK: - Links

    private enum Links {
        static let appURL = "instagram://app"
        static let webURL = "https://instagram.com"
    }

    // MARK: - Strings

    private enum Strings {
        static let topLabelText = "Creator /Business account".localized()
        static let topTextViewText = "topTextViewText".localized()
        static let bottomTextViewText = "bottomTextViewText".localized()
        static let bottomLabelText = "🔗    If your page is not linked:".localized()
        static let buttonTitle = "Open Instagram".localized()
    }

    // MARK: - UI Components

    private lazy var topLabel: UILabel = {
        let label = makeLabel()
        label.text = Strings.topLabelText
        return label
    }()

    private lazy var bottomLabel: UILabel = {
        let label = makeLabel()
        label.text = Strings.bottomLabelText
        return label
    }()

    private lazy var topTextView: UITextView = {
        let textView = makeTextView()
        textView.text = Strings.topTextViewText
        textView.isScrollEnabled = false
        textView.heightAnchor.constraint(equalToConstant: Constants.textViewHeight).isActive = true
        return textView
    }()

    private lazy var bottomTextView: UITextView = {
        let textView = makeTextView()
        textView.text = Strings.bottomTextViewText
        textView.isScrollEnabled = false
        textView.heightAnchor.constraint(equalToConstant: Constants.textViewHeight).isActive = true
        return textView
    }()
    
    private var instagramIconAttachment: NSTextAttachment {
        let icon = NSTextAttachment()
        icon.image = UIImage(named: "igColor")
        icon.bounds = Constants.iconBounds
        return icon
    }
    
    private lazy var stackView: UIStackView = {
        let stack = makeStackView()
        return stack
    }()
    
    private var openInstagramButton: UIButton {
        let btn = UIButton()
        btn.setTitleColor(customPurple, for: .normal)
        btn.setTitle(Strings.buttonTitle, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(goProfile(_:)), for: .touchUpInside)
        return btn
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkIsFirstTime()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = bkgdColor
        view.applyBlur()
        placeHelpButtonForSetupIGProWeb()
        placeTopRightButton(arrowButton: false)
        setupCustomStackHTSProIG()
        setupInstagramButton()
    }

    // MARK: - Private Methods

    private func makeLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: Constants.labelHeight).isActive = true
        label.widthAnchor.constraint(equalToConstant: Constants.textViewWidth).isActive = true
        return label
    }

    private func makeTextView() -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.textAlignment = .left
        textView.tintColor = .black
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.widthAnchor.constraint(equalToConstant: Constants.textViewWidth).isActive = true
        return textView
    }

    private func makeStackView() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }

    private func setupCustomStackHTSProIG() {
        let containerStackView = stackView
        containerStackView.distribution = .equalSpacing
        containerStackView.alignment = .center
        containerStackView.spacing = Constants.stackViewSpacing

        let subStack1 = makeStackView()
        subStack1.addArrangedSubview(topLabel)
        subStack1.addArrangedSubview(topTextView)

        let subStack2 = makeStackView()
        subStack2.addArrangedSubview(bottomLabel)
        subStack2.addArrangedSubview(bottomTextView)

        containerStackView.addArrangedSubview(subStack1)
        containerStackView.addArrangedSubview(subStack2)
        view.addSubview(containerStackView)

        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(attachment: instagramIconAttachment))
        attributedString.append(NSAttributedString(string: "  " + Strings.topLabelText))
        topLabel.attributedText = attributedString
    }

    private func setupInstagramButton() {
        let button = openInstagramButton
        view.addSubview(button)
        button.heightAnchor.constraint(equalToConstant: Constants.openInstagramBtnHeight).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(
            equalTo: view.bottomAnchor, constant: Constants.openInstagramBtnBottomPadding).isActive = true
    }

    private func checkIsFirstTime() {
        let key = SettingsKey.setupInfoShown
        if !UserDefaults.standard.bool(forKey: key) {
            UserDefaults.standard.set(true, forKey: key)
        }
    }

    @objc private func goProfile(_ sender: Any) {
        ExternalLinkOpener.openAppURL(appURL: Links.appURL, webURL: Links.webURL)
    }
}
