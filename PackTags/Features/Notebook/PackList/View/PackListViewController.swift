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

private enum Constants {
    /// Leaves the copy feedback visible before the app switches to Instagram.
    static let afterCopy: TimeInterval = 0.8
    /// Lets the Instagram transition start before reordering the table.
    static let afterReorder: TimeInterval = 0.5
    /// Each row is a sixth of the visible table.
    static let rowsPerScreen: CGFloat = 6
}

final class PackListViewController: CoverImageTableViewController {

    private let viewModel: PackListViewModel

    /// Wired by the coordinator: opens the theme editor, highlighting the
    /// given pack when non-nil.
    var onEditTheme: ((String?) -> Void)?

    private let composeButton = UIBarButtonItem()
    private let instaButton = UIBarButtonItem()
    private let pasteboard = UIPasteboard.general

    private var packs: [String] { viewModel.packs }

    private var coverImage: UIImage? {
        viewModel.coverImageData.flatMap(UIImage.init(data:))
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
        self.title = viewModel.title

        composeButton.image = UIImage(named: "EditPic")
        composeButton.target = self
        composeButton.action = #selector(didTapCompose)

        instaButton.image = UIImage(named: "insta2")
        instaButton.target = self
        instaButton.action = #selector(didTapInstagram)

        navigationItem.rightBarButtonItems = [composeButton, instaButton]

        tableView.register(PackCell.self)
        tableView.backgroundColor = .colorBkgd

        viewModel.loadPacks()
        barBackgroundColor = .colorBkgd
        setCoverImage(coverImage)
    }

    @objc private func didTapInstagram() {
        statusAutoDirectToInstagram()
    }
}

// MARK: - Editor round trip (called by the coordinator)
extension PackListViewController {
    func editorDidSave() {
        viewModel.loadPacks()
        tableView.reloadData()
        navigationItem.title = viewModel.title
        setCoverImage(coverImage)
        suspendsCoverStatusBarStyle = false
    }

    func editorDidClose() {
        suspendsCoverStatusBarStyle = false
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.frame.size.height / Constants.rowsPerScreen
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Cell configuration & swipe
extension PackListViewController {
    private func configureCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(PackCell.self, for: indexPath)

        let pack = self.packs[indexPath.row]
        let row = viewModel.packRow(at: indexPath.row)

        cell.cellLabel.text = row?.firstTag
        cell.subButton.setTitle(row?.badge, for: .normal)

        cell.buttonTapCallback = { [weak self] in
            self?.pasteboard.string = pack
            self?.goInsta(packIdx: indexPath.row)
        }

        cell.subButtonTapCallback = { [weak self] in
            guard let self else { return }
            let message = pack.isEmpty ? Strings.tapPencil : pack
            Alerts.tapToDismiss(from: self, title: "", message: message)
        }

        if indexPath.row == 0 {
            cell.roundTopCorners(radius: coverCornerRadius)
        }

        return cell
    }

    private func addSCellSwipeAccessory(indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .normal, title: Strings.show) { [weak self] (contextualAction, view, boolValue) in
            guard let self else { return }
            self.presentThemeVC(showingPack: self.packs[indexPath.row])
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])

        contextItem.backgroundColor = .customBarTint
        return swipeActions
    }
}

// MARK: - Compose & show
extension PackListViewController {
    @objc private func didTapCompose() {
        presentThemeVC(showingPack: nil)
    }

    /// Opens the editor; a non-nil pack gets highlighted there.
    private func presentThemeVC(showingPack pack: String?) {
        suspendsCoverStatusBarStyle = true
        onEditTheme?(pack)
    }
}

// MARK: - Instagram redirect
extension PackListViewController {
    func goInsta(packIdx: Int) {
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(Constants.afterCopy))
            guard let self else { return }
            let action = self.viewModel.postCopyAction()

            if let appURL = action.instagramAppURL, let webURL = action.instagramWebURL {
                ExternalLinkOpener.openAppURL(appURL: appURL, webURL: webURL)
            }
            if action.shouldMovePackToBottom {
                try? await Task.sleep(for: .seconds(Constants.afterReorder))
                self.viewModel.movePack(at: packIdx)
                self.tableView.reloadData()
            }
        }
    }

    private func statusAutoDirectToInstagram() {
        switch viewModel.toggleInstagramRedirect() {
        case .promptForUsername:
            promptForInstagramUsername()
        case .enabled(let username):
            Alerts.tapToDismiss(from: self, title: username, message: Strings.redirectionAlertMessage)
        case .disabled(let username):
            Alerts.tapToDismiss(from: self, title: username, message: Strings.stopRedirectionAlertMessage)
        }
    }

    private func promptForInstagramUsername() {
        Alerts.showTextInputAlert(
            from: self,
            title: Strings.instagram,
            message: Strings.username,
            placeholder: Strings.enterUsername
        ) { [weak self] inputName in
            guard let self else { return }
            let name = self.viewModel.saveInstagramUsername(inputName)
            Alerts.tapToDismiss(
                from: self,
                title: name,
                message: Strings.redirectionAlertMessage + "  \n\n " + Strings.undoRedirection
            )
        }
    }

}
