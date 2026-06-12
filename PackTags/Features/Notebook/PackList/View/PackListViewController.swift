import UIKit
import TableViewControllerCoverKit

private enum Strings {
    static let instagram = "Instagram".localized()
    static let username = "Username".localized()
    static let enterUsername = "Enter Username".localized()
    static let redirectionAlertMessage = "PackTags will redirect you to this account each, time the copy button is tapped.".localized()
    static let stopRedirectionAlertMessage = "PackTags will stop redirecting you to this account, each time the copy button is tapped.".localized()
    static let undoRedirection = "Tap the button again to undo.".localized()
    static let tapPencil = "Tap the Pencil button to add Hashtags.".localized()
    static let show = "Show".localized()
}

class PackListViewController: CoverImageTableViewController {

    weak var coordinator: (any ThemeCoordinatorProtocol)?
    let viewModel: PackListViewModel

    private let composeButton = UIBarButtonItem()
    private let instaButton = UIBarButtonItem()
    private let pasteboard = UIPasteboard.general
    private var chosenPack = String()

    private var packs: [String] { viewModel.packs }

    private var coverImage: UIImage? {
        viewModel.theme.image.flatMap(UIImage.init(data:))
    }

    init(style: UITableView.Style, viewModel: PackListViewModel) {
        self.viewModel = viewModel
        super.init(style: style)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad(){
        super.viewDidLoad()
        self.title = viewModel.theme.name

        composeButton.image = UIImage(named: "EditPic")
        composeButton.target = self
        composeButton.action = #selector(didTapCompose)

        instaButton.image = UIImage(named: "insta2")
        instaButton.target = self
        instaButton.action = #selector(didTapInstagram)

        navigationItem.rightBarButtonItems = [composeButton, instaButton]

        tableView.register(PackCell.self, forCellReuseIdentifier: "PackCell")
        tableView.rowHeight = 81
        tableView.backgroundColor = bkgdColor

        loadPacks()
        barBackgroundColor = bkgdColor
        setCoverImage(coverImage)
    }

    @objc private func didTapInstagram() {
        statusAutoDirectToInstagram()
    }
}

// MARK: - Loading
extension PackListViewController {
    fileprivate func loadPacks() {
        viewModel.loadPacks()
    }

    fileprivate func updatePackListViewController() {
        loadPacks()
        tableView.reloadData()
        navigationItem.title = viewModel.theme.name
        setCoverImage(coverImage)
    }
}

// MARK: - Data source & delegate
extension PackListViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
      return addSCellSwipeAccessory(indexPath: indexPath)
  }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return tableView.frame.size.height/6
        //return UITableView.automaticDimension //
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Cell configuration & swipe
extension PackListViewController {
    private func configureCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PackCell", for: indexPath) as? PackCell
        else {
            fatalError("The dequeued cell is not an instance of PackCell.")
        }

        let pack = self.packs[indexPath.row]
        let row = viewModel.packRow(at: indexPath.row)

        cell.cellLabel.text = row?.firstTag
        cell.subButton.setTitle(row?.badge, for: .normal)

        cell.buttonTapCallback = { [weak self] in
            self?.pasteboard.string = pack
            self?.goInsta(packIdx: indexPath.row)
        }

        cell.subButtonTapCallback = { [weak self] in
            let message = pack.isEmpty ? Strings.tapPencil : pack
            self?.subBtnAlert(title: "", message: message)
        }

        if indexPath.row == 0 {
            cell.roundTopCorners(radius: coverCornerRadius)
        }

        return cell
    }

    private func addSCellSwipeAccessory(indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .normal, title: Strings.show) { [weak self] (contextualAction, view, boolValue) in
            guard let self else { return }
            self.chosenPack = self.packs[indexPath.row]
            self.presentThemeVC(fromSwipe: true)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])

        contextItem.backgroundColor = customBarTint
        return swipeActions
    }
}

// MARK: - Compose & show
extension PackListViewController {
    @objc private func didTapCompose() {
        presentThemeVC(fromSwipe: false)
    }

    private func presentThemeVC(fromSwipe: Bool) {
        suspendsCoverStatusBarStyle = true
        coordinator?.showThemeEditor(
            for: viewModel.theme,
            fromSwipe: fromSwipe,
            chosenPack: fromSwipe ? chosenPack : "",
            onSave: { [weak self] in
                self?.updatePackListViewController()
                self?.suspendsCoverStatusBarStyle = false
            },
            onCancel: { [weak self] in
                self?.suspendsCoverStatusBarStyle = false
            }
        )
    }
}

// MARK: - Instagram redirect
extension PackListViewController {
    private enum Delay {
        /// Leaves the copy feedback visible before the app switches to Instagram.
        static let afterCopy: TimeInterval = 0.8
    }

    func goInsta(packIdx: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Delay.afterCopy) { [weak self] in
            guard let self else { return }
            let action = self.viewModel.postCopyAction()

            if action.shouldMovePackToBottom {
                self.copiedPacksToBottom(packIdx: packIdx)
            }
            if let appURL = action.instagramAppURL, let webURL = action.instagramWebURL {
                ExternalLinkOpener.openAppURL(appURL: appURL, webURL: webURL)
            }
        }
    }

    fileprivate func statusAutoDirectToInstagram() {
        switch viewModel.toggleInstagramRedirect() {
        case .promptForUsername:
            promptForInstagramUsername()
        case .enabled(let username):
            subBtnAlert(title: username, message: Strings.redirectionAlertMessage)
        case .disabled(let username):
            subBtnAlert(title: username, message: Strings.stopRedirectionAlertMessage)
        }
    }

    private func promptForInstagramUsername() {
        Alerts.showTextInputAlert(
            targetVC: self,
            title: Strings.instagram,
            message: Strings.username,
            placeholder: Strings.enterUsername
        ) { [weak self] inputName in
            guard let self else { return }
            let name = self.viewModel.saveInstagramUsername(inputName)
            self.subBtnAlert(
                title: name,
                message: Strings.redirectionAlertMessage + "  \n\n " + Strings.undoRedirection
            )
        }
    }

    //If redirected to instagram after copy, move pack to bottom
    private func copiedPacksToBottom(packIdx: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewModel.movePack(at: packIdx)
            self.tableView.reloadData()
        }
    }
}
