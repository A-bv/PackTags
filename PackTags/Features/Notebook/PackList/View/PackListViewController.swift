import UIKit
import TableViewControllerCoverKit

private enum Chrome {
    static let fadeDistance: CGFloat = 50
}

class PackListViewController: CoverImageTableViewController {

    weak var coordinator: (any ThemeCoordinatorProtocol)?
    let viewModel: PackListViewModel

    init(style: UITableView.Style, viewModel: PackListViewModel) {
        self.viewModel = viewModel
        super.init(style: style)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let composeButton = UIBarButtonItem()
    let instaButton = UIBarButtonItem()

    var packs: [String] { viewModel.packs }
    
    let pasteboard = UIPasteboard.general
    var chosenPack = String()

    // MARK: - Bar fade (app chrome, deliberately outside the package)

    /// Negative while the bar floats over the image (light status bar),
    /// 0...1 while fading in over the content.
    private var barAlpha: CGFloat = 0 {
        didSet { setNeedsStatusBarAppearanceUpdate() }
    }

    /// Set while a modal covers this screen so the status bar reads normally.
    var overridesStatusBarToDefault = false {
        didSet { setNeedsStatusBarAppearanceUpdate() }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if overridesStatusBarToDefault { return .default }
        return barAlpha < 0 ? .lightContent : .default
    }
    
    // MARK: - Interface
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

        loadPacks() //load
        setCoverImage(coverImage)
        tableView.backgroundColor = bkgdColor
        setNavBarTransparent(alpha: barAlpha)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        let fadeStart = currentNavBarHeight + 2 * statusBarHeight
        barAlpha = min(1, (scrollView.contentOffset.y + fadeStart) / Chrome.fadeDistance)
        setNavBarTransparent(alpha: barAlpha)
    }

    private var coverImage: UIImage? {
        viewModel.theme.image.flatMap(UIImage.init(data:))
    }

    @objc private func didTapInstagram() {
        statusAutoDirectToInstagram()
    }
}

// MARK: - Loading
extension PackListViewController {
    func loadPacks() {
        viewModel.loadPacks()
    }

    func updatePackListViewController() {
        loadPacks()
        tableView.reloadData()
        navigationItem.title = viewModel.theme.name
        setCoverImage(coverImage)
    }
}
