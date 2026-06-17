import UIKit
import TapTagKit

private enum Constants {
    static let contentInset: CGFloat = 8
    static let coverImageSize = CGSize(width: 600, height: 600)
    static let thumbnailSize = CGSize(width: 135.333, height: 135.333)
    static let jpegQuality: CGFloat = 0.8
    static let highlightAlpha: CGFloat = 0.3
}

private enum Strings {
    static let rename = "Rename".localized()
    static let editPicture = "Edit picture".localized()
    static let textRecognition = "Text Recognition".localized()
    static let shuffleHashtags = "Shuffle hashtags".localized()
    static let menuSectionEdit = "Edit...".localized()
    static let menuSectionImport = "Import...".localized()
    static let menuSectionManage = "Manage...".localized()
    static let themeOptions = "Theme options".localized()
}

final class ThemeEditorViewController: UIViewController {

    //MARK: - Dependencies

    private let viewModel: ThemeEditorViewModel

    //MARK: - UI

    private let themeTextView: TapTextView = {
        let textView = TapTextView()
        textView.configuration = .init(
            toolbarInfoTitle: "Actions on selected hashtags".localized(),
            toolbarInfoMessage: "tapTextViewToolBarDescriptionMessage".localized(),
            selectButtonAccessibilityLabel: "Select hashtags".localized(),
            placeholder: "Paste or enter your hashtags...".localized(),
            avoidsKeyboard: true)
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

    private lazy var saveButton: UIBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .save,
        target: self,
        action: #selector(save))

    private lazy var cancelButton: UIBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .cancel,
        target: self,
        action: #selector(cancel))

    private let findButton = KeyboardFindButton()

    private let spinner = UIActivityIndicatorView()

    //MARK: - State

    private var themeImage = DarkMode.isDarkMode() ? UIImage(named: "Logo-BlackLong") : UIImage(named: "Logo-PurpleLong")

    /// Set by the coordinator when this editor opens from a pack's "show"
    /// action; that pack gets highlighted and scrolled into view.
    var packToHighlight: String?

    private let imagePicker = ThemeImagePicker()

    //MARK: - Callbacks

    var onSave: ((ThemeCD?) -> Void)?
    var onCancel: (() -> Void)?

    //MARK: - Init

    init(viewModel: ThemeEditorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupViewHierarchy()
        setupConstraints()
        setupNavigationItems()
        setupSpinner()
        configureTextView()
        findButton.attach(to: themeTextView, in: view)

        loadEntries()
        updateSaveButtonState()

        if viewModel.isNewTheme { showNameThemeAlert() }
        if let pack = packToHighlight {
            highlight(pack)
            packToHighlight = nil
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    //MARK: - Setup

    private func setupViewHierarchy() {
        view.addSubview(themeTextView)
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            themeTextView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: Constants.contentInset),
            themeTextView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Constants.contentInset),
            themeTextView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Constants.contentInset),
            themeTextView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -Constants.contentInset),
        ])
    }

    private func setupNavigationItems() {
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItems = [saveButton, buttonMenu(), themeTextView.makeTapTextViewButton()]
        navigationController?.view.tintColor = UITextView.appearance().tintColor
    }

    private func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func configureTextView() {
        themeTextView.tagDelegate = self
        themeTextView.addTagSelectorToolBar(viewController: self)
    }

    private func loadEntries() {
        if let text = viewModel.contentForDisplay() {
            themeTextView.text = text
        }
        if let imageData = viewModel.theme?.image {
            themeImage = UIImage(data: imageData)
        }
    }

    private func updateSaveButtonState() { saveButton.isEnabled = viewModel.canSave }

    //MARK: - Save

    @objc private func save() {
        let imageData = themeImage?.jpegData(compressionQuality: Constants.jpegQuality)
        let thumbnailData = themeImage?.resized(to: Constants.thumbnailSize)
            .jpegData(compressionQuality: Constants.jpegQuality)
        viewModel.save(rawText: themeTextView.text, imageData: imageData, thumbnailData: thumbnailData)
        let savedTheme = viewModel.theme
        dismiss(animated: true) { [weak self] in
            self?.onSave?(savedTheme)
        }
    }

    //MARK: - Cancel

    // The coordinator always presents this editor modally (inside its own
    // navigation controller), so dismissal is the only exit.
    @objc private func cancel() {
        dismiss(animated: true) { [weak self] in
            self?.onCancel?()
        }
    }
}

//MARK: - Options menu

extension ThemeEditorViewController {

    private func buttonMenu() -> UIBarButtonItem {
        let editName = UIAction(
            title: Strings.rename,
            image: UIImage(systemName: "tag")
        ) { [weak self] _ in
            self?.showNameThemeAlert()
        }

        let editPicture = UIAction(
            title: Strings.editPicture,
            image: UIImage(systemName: "photo.on.rectangle.angled")
        ) { [weak self] _ in
            self?.pickCoverImage()
        }

        let textRecon = UIAction(
            title: Strings.textRecognition,
            image: UIImage(systemName: "doc.text.viewfinder")
        ) { [weak self] _ in
            self?.importTextFromPhoto()
        }

        let shuffle = UIAction(
            title: Strings.shuffleHashtags,
            image: UIImage(systemName: "shuffle.circle")
        ) { [weak self] _ in
            guard let self, let textToShuffle = self.themeTextView.text else { return }
            self.themeTextView.text = self.viewModel.shuffleContent(rawText: textToShuffle)
        }

        let edit = UIMenu(
            title: Strings.menuSectionEdit,
            options: .displayInline,
            children: [editName, editPicture])

        let htgImport = UIMenu(
            title: Strings.menuSectionImport,
            options: .displayInline,
            children: [textRecon])

        let manage = UIMenu(
            title: Strings.menuSectionManage,
            options: .displayInline,
            children: [shuffle])

        let item = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            primaryAction: nil,
            menu: UIMenu(title: "", children: [edit, htgImport, manage]))
        item.accessibilityLabel = Strings.themeOptions
        return item
    }
}

//MARK: - Cover image & text recognition

extension ThemeEditorViewController {

    private func pickCoverImage() {
        imagePicker.present(from: self) { [weak self] image in
            self?.themeImage = image.resized(to: Constants.coverImageSize)
        }
    }

    private func importTextFromPhoto() {
        imagePicker.present(from: self) { [weak self] image in
            guard let self else { return }
            self.spinner.startAnimating()
            Task {
                let text = await TextRecognitionUtility.recognizeText(image: image)
                if !text.isEmpty {
                    self.themeTextView.text = self.viewModel.contentByPrepending(
                        recognizedText: text,
                        to: self.themeTextView.text ?? "")
                }
                self.spinner.stopAnimating()
            }
        }
    }
}

//MARK: - Theme name alert

extension ThemeEditorViewController {

    private func showNameThemeAlert() {
        let alert = viewModel.nameAlert
        Alerts.showTextInputAlert(
            from: self,
            title: alert.title,
            message: alert.message,
            placeholder: alert.placeholder
        ) { [weak self] inputName in
            self?.viewModel.themeTitle = inputName
            self?.updateSaveButtonState()
        }
    }
}

//MARK: - Pack highlight (PackList "Show" flow)

extension ThemeEditorViewController {

    private func highlight(_ pack: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.themeTextView.text = self.themeTextView.text + "\n" // Last for highlight
            guard let match = self.themeTextView.text.range(of: pack + "\n") else { return }

            // Assigning attributedText forces a clean relayout; mutating
            // textStorage directly leaves TextKit 2 with stale fragments
            // that render as ghost text.
            let highlight = NSRange(match, in: self.themeTextView.text)
            let highlighted = NSMutableAttributedString(attributedString: self.themeTextView.attributedText)
            highlighted.addAttribute(
                .backgroundColor,
                value: self.themeTextView.tintColor.withAlphaComponent(Constants.highlightAlpha),
                range: highlight)
            self.themeTextView.attributedText = highlighted
            self.themeTextView.scrollRangeToVisible(highlight)
        }
    }
}

//MARK: - TapTextViewDelegate

extension ThemeEditorViewController: @preconcurrency TapTextViewDelegate {

    func tapTextViewDidStartSelection(_ textView: TapTextView) {
        navigationController?.setToolbarHidden(false, animated: false)
    }

    func tapTextViewDidFinishSelection(_ textView: TapTextView) {
        navigationController?.setToolbarHidden(true, animated: false)
    }
}
