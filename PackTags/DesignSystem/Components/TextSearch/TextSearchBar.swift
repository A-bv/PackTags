import UIKit

/// A drop-in search bar for any UITextView: live match highlighting,
/// scroll-to-match, a results counter, and an edit lock so typing can't
/// mangle the text mid-search.
///
/// Generic on purpose — no knowledge of its host feature, so it can be
/// extracted as a standalone package (a pre-iOS 16 alternative to
/// UIFindInteraction). Place the bar above the text view and
/// `resultsLabel` wherever the match count should appear, then
/// `attach(to:)` the text view.
final class TextSearchBar: UIStackView {
    private enum Strings {
        static let placeholder = "Search ..."
        static let edit = "Edit"
        static let done = "Done"
        static let results = "results".localized()
        static let locked = "\u{1F512}"
        static let unlocked = "\u{1F513}"
    }

    private enum Constants {
        static let buttonSide: CGFloat = 30
    }

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = Strings.placeholder
        searchBar.autocorrectionType = .no
        searchBar.spellCheckingType = .no
        searchBar.keyboardType = .twitter
        searchBar.smartDashesType = .no
        searchBar.smartQuotesType = .no
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private let lockLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.unlocked
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.edit, for: .normal)
        button.addTarget(self, action: #selector(unlockEditing), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.done, for: .normal)
        button.addTarget(self, action: #selector(endSearch), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    /// The match counter. Not part of the bar's own layout so the host can
    /// place it independently (e.g. below the text view).
    let resultsLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private weak var textView: UITextView?

    /// Fired when search mode starts (true) or ends (false).
    var onActiveChange: ((Bool) -> Void)?

    init() {
        super.init(frame: .zero)
        axis = .horizontal
        spacing = 2
        alignment = .center
        distribution = .fill
        translatesAutoresizingMaskIntoConstraints = false

        [searchBar, lockLabel, editButton, doneButton].forEach(addArrangedSubview)
        searchBar.delegate = self

        NSLayoutConstraint.activate([
            editButton.heightAnchor.constraint(equalToConstant: Constants.buttonSide),
            editButton.widthAnchor.constraint(equalTo: editButton.heightAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.buttonSide),
            doneButton.widthAnchor.constraint(equalTo: doneButton.heightAnchor),
        ])
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - API

    func attach(to textView: UITextView) {
        self.textView = textView
        isHidden = true
        resultsLabel.isHidden = true
    }

    func beginSearch() {
        isHidden = false
        textView?.setCursorPositionAtStart()
        searchBar.becomeFirstResponder()
        onActiveChange?(true)
    }

    @objc private func endSearch() {
        searchBar.text = ""
        textView?.highlightColorsForSearchedWords(keyword: [""])
        isHidden = true
        resultsLabel.isHidden = true
        textView?.isEditable = true
        onActiveChange?(false)
        window?.endEditing(true)
    }

    @objc private func unlockEditing() {
        textView?.isEditable = true
        lockLabel.text = Strings.unlocked
        window?.endEditing(true)
        editButton.isEnabled = false
        textView?.becomeFirstResponder()
    }
}

// MARK: - UISearchBarDelegate

extension TextSearchBar: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let textView else { return }
        textView.highlightColorsForSearchedWords(keyword: [searchText])
        textView.scrollToSubstring(substring: searchText)
        let matches = textView.getEveryHighlightedWordPosition(word: searchBar.text ?? "")
        if searchBar.text?.isEmpty == false {
            resultsLabel.isHidden = false
            resultsLabel.text = "\(matches.count) " + Strings.results
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        lockLabel.text = Strings.locked
        editButton.isEnabled = true
        textView?.isEditable = false
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        window?.endEditing(true)
    }
}
