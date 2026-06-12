import UIKit

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
