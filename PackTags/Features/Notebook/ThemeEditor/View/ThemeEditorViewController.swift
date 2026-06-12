import UIKit
import TextSearchKit

class ThemeEditorViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate {

    let viewModel: ThemeEditorViewModel

    init(viewModel: ThemeEditorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - UI

    let themeTextView: TapTextView = {
        let textView = TapTextView()
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.textColor = .label
        textView.backgroundColor = .systemBackground
        textView.keyboardDismissMode = .interactive
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.keyboardType = .twitter
        textView.smartQuotesType = .no
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    lazy var saveButton: UIBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .save,
        target: self,
        action: #selector(save))

    lazy var cancelButton: UIBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(cancel))

    let searchBar = TextSearchBar(configuration: .init(resultsSuffix: "results".localized()))

    private lazy var outerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [searchBar, themeTextView, searchBar.resultsLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    //MARK: - Model

    var themeImageView = DarkMode.isDarkMode() ? UIImage(named: "Logo-BlackLong") : UIImage(named: "Logo-PurpleLong")

    //"show" button (PackTableVC) variables
    var isFromShow = false
    var packFromShow = String()

    //Text Recognition in images (iOS < 11) 1/2
    var recognizeText = false

    // Processing spinner
    let spinner = UIActivityIndicatorView()

    var buttonMenuThemeOptions: UIBarButtonItem {
        return buttonMenu()
    }

    //MARK: - Callbacks
    var onSave: ((ThemeCD?) -> Void)?
    var onCancel: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupViewHierarchy()
        setupConstraints()

        navigationItem.leftBarButtonItem = cancelButton
        navigationController?.view.tintColor = UITextView.appearance().tintColor

        if viewModel.isNewTheme { showNameThemeAlert() }

        loadbuttons()
        loadEntries()
        configureTextView()

        loadProcessingSpinner()

        searchBar.attach(to: themeTextView)

        updateSaveButtonState() // Enable save button if title != empty

        if isFromShow == true {
            isScreenLoadedFromShowButton()
            isFromShow = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    //MARK: - Layout

    private func setupViewHierarchy() {
        view.addSubview(outerStack)
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            outerStack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            outerStack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            outerStack.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),

        ])
    }

    //MARK: - Setup
    func updateSaveButtonState() { saveButton.isEnabled = viewModel.canSave }

    private func loadEntries() {
        guard viewModel.theme != nil else { return }
        if let text = viewModel.contentForDisplay() {
            themeTextView.text = text
        }
        if let imageData = viewModel.theme?.image {
            themeImageView = UIImage(data: imageData)
        }
    }

    private func loadProcessingSpinner() {
        spinner.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        self.view.addSubview(spinner)
    }

    private func loadbuttons() {
        navigationItem.rightBarButtonItems = [saveButton, buttonMenuThemeOptions, themeTextView.makeTapTextViewButton()]
    }

    private func configureTextView() {
        themeTextView.delegate = self
        themeTextView.tagDelegate = self
        themeTextView.setPlaceholder()
        themeTextView.addTagSelectorToolBar(viewController: self)
        themeTextView.notHiddenByKeyboard()
    }

    //MARK: - Save
    private enum SaveConstants {
        static let thumbnailSize = CGSize(width: 135.333, height: 135.333)
        static let jpegQuality: CGFloat = 0.8
    }

    @objc func save() {
        let imageData = themeImageView?.jpegData(compressionQuality: SaveConstants.jpegQuality)
        let thumbnailData = themeImageView?.resized(to: SaveConstants.thumbnailSize)
            .jpegData(compressionQuality: SaveConstants.jpegQuality)
        let isUpdatingExistingTheme = !viewModel.isNewTheme
        viewModel.save(rawText: themeTextView.text, imageData: imageData, thumbnailData: thumbnailData)
        let savedTheme = viewModel.theme
        dismiss(animated: true) { [weak self] in
            self?.onSave?(savedTheme)
            if isUpdatingExistingTheme {
                StoreKitHelper.displayStoreKit()
            }
        }
    }
}

extension ThemeEditorViewController {
    //MARK: - UITextViewDelegate
    //Placeholder
    func textViewDidChange(_ textView: UITextView) {
        themeTextView.checkPlaceholder()
    }
}

// Status Bar color
extension ThemeEditorViewController {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return  .default
    }
}

extension ThemeEditorViewController: TapTextViewDelegate {
    func tapTextViewDidStartSelection(_ textView: TapTextView) {
        navigationController?.setToolbarHidden(false, animated: false)
    }

    func tapTextViewDidFinishSelection(_ textView: TapTextView) {
        navigationController?.setToolbarHidden(true, animated: false)
    }
}

// MARK: - Cancel
extension ThemeEditorViewController {
    @objc func cancel() {
        if presentingViewController is UINavigationController {
            dismiss(animated: true) { [weak self] in
                self?.onCancel?()
            }
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: false)
            onCancel?()
        } else {
            dismiss(animated: true) { [weak self] in
                self?.onCancel?()
            }
        }
    }
}

// MARK: - Pack highlight (PackList "Show" flow)
extension ThemeEditorViewController {
    private func isScreenLoadedFromShowButton() {
        DispatchQueue.main.async { [self] in
            themeTextView.text = themeTextView.text + "\n" // Last for highlight
            guard let match = themeTextView.text.range(of: packFromShow + "\n") else { return }

            let highlight = NSRange(match, in: themeTextView.text)
            themeTextView.textStorage.addAttribute(
                .backgroundColor,
                value: UIColor.systemYellow.withAlphaComponent(0.5),
                range: highlight)
            themeTextView.scrollRangeToVisible(highlight)
        }
    }
}
