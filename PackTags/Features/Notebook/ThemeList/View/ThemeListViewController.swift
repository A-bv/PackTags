import UIKit

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
            self?.tableView.reloadData()
        }
        viewModel.loadThemes()
        addFloatingButton()
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
