//
//  ViewController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.09.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class ThemeEditorViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate {

    deinit {
        print("deinit ThemeEditorViewController")
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

    let toolBarSearch: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search ..."
        searchBar.autocorrectionType = .no
        searchBar.spellCheckingType = .no
        searchBar.keyboardType = .twitter
        searchBar.smartDashesType = .no
        searchBar.smartQuotesType = .no
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    let searchLockLabel: UILabel = {
        let label = UILabel()
        label.text = "Lk"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var searchEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.addTarget(self, action: #selector(toolBarDown(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var searchDoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.addTarget(self, action: #selector(searchBarOK(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var searchView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [toolBarSearch, searchLockLabel, searchEditButton, searchDoneButton])
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let searchCountLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var outerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [searchView, themeTextView, searchCountLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    //MARK: - Model

    var theme: ThemeCD?

    var themeImageView = DarkMode.isDarkMode() ? UIImage(named: "Logo-BlackLong") : UIImage(named: "Logo-PurpleLong")

    var themeTitle = String()

    var isNotNewTheme = false

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

    var isSearchMode: Bool = false {
        didSet {
            // buttonMenuThemeOptions.isEnabled = !isSearchMode
            // TODO: issue can't disable button in search mode
        }
    }

    var numTagsPerPack = QuantityPickerData.selectedValue

    //MARK: - Callbacks
    var onSave: ((ThemeCD?) -> Void)?
    var onCancel: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupViewHierarchy()
        setupConstraints()

        toolBarSearch.delegate = self
        navigationItem.leftBarButtonItem = cancelButton
        navigationController?.view.tintColor = UITextView.appearance().tintColor

        if isNotNewTheme == false { showNameThemeAlert() }

        loadbuttons()
        loadEntries()
        configureTextView()

        loadProcessingSpinner()

        initSearchToolbar() // Search toolbar

        updateSaveButtonState() // Enable save button if title != empty

        if isFromShow == true {
            isScreenLoadedFromShowButton()
            isFromShow = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
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

            searchEditButton.heightAnchor.constraint(equalToConstant: 30),
            searchEditButton.widthAnchor.constraint(equalTo: searchEditButton.heightAnchor),
            searchDoneButton.heightAnchor.constraint(equalToConstant: 30),
            searchDoneButton.widthAnchor.constraint(equalTo: searchDoneButton.heightAnchor),
        ])
    }

    //MARK: - Setup
    func updateSaveButtonState() { saveButton.isEnabled = !themeTitle.isEmpty }

    private func loadEntries() {
        guard let theme else { return }
        themeTitle = theme.name ?? ""

        //Packing by 30 from Core Data on textView
        if let content = theme.content {
            let text = content
            let hashtags = Unique.reorganizeTags(from: text, with: numTagsPerPack)
            themeTextView.text = hashtags
        }

        //image
        if let image = theme.image {
            themeImageView = UIImage(data: image)
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
    @objc func save() {
        handleSelectedThemeData()
        let savedTheme = theme
        dismiss(animated: true) { [weak self] in
            self?.onSave?(savedTheme)
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
