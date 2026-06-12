import UIKit
import CoreData

class ThemeListViewController: UITableViewController {

    weak var coordinator: (any ThemeCoordinatorProtocol)?
    let viewModel: ThemeListViewModel

    init(style: UITableView.Style, viewModel: ThemeListViewModel) {
        self.viewModel = viewModel
        super.init(style: style)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let smartGButton = UIBarButtonItem()
    let settingsButton = UIBarButtonItem()
    let analyticsButton = UIBarButtonItem()

    /// Decoded thumbnails keyed by theme; cleared on every data reload so
    /// scrolling never re-decodes JPEG data row by row.
    private let thumbnailCache = NSCache<NSManagedObjectID, UIImage>()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyThemedNavigationBarStyle()
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureTableView()
        viewModel.onUpdate = { [weak self] in
            self?.thumbnailCache.removeAllObjects()
            self?.tableView.reloadData()
        }
        viewModel.loadThemes()
        addFloatingButton()
    }

    func thumbnail(for theme: ThemeCD) -> UIImage? {
        if let cached = thumbnailCache.object(forKey: theme.objectID) { return cached }
        guard let data = theme.thumbnail, let image = UIImage(data: data) else { return nil }
        thumbnailCache.setObject(image, forKey: theme.objectID)
        return image
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNewUserFlow()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateRowHeightIfNeeded()
    }
}

//MARK: - Update colors when light/dark mode
extension ThemeListViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLogo ()
        navigationController?.navigationBar.putShadow()
    }
}
