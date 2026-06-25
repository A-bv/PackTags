import UIKit
import CoreData

final class ThemeListViewController: UITableViewController {

    private enum Constants {
        static let tableViewBottomPadding: CGFloat = 14
        static let rowMinimumHeight: CGFloat = 164
        static let rowsPerScreen: CGFloat = 4
        static let rowsPerScreenCompact: CGFloat = 3
        static let reorderPressDuration: TimeInterval = 0.8
    }

    private enum Strings {
        static let deleteConfirmationMessage = "Delete this theme?\n\nThis action is irreversible.".localized()
        static let yes = "Yes".localized()
        static let cancel = "Cancel".localized()
    }

    // MARK: - Dependencies

    private let viewModel: ThemeListViewModel

    // MARK: - Callbacks

    var onViewDidAppear: (() -> Void)?

    // MARK: - UI

    private let smartGButton = UIBarButtonItem()
    private let settingsButton = UIBarButtonItem()
    private let analyticsButton = UIBarButtonItem()

    // MARK: - State

    /// Decoded thumbnails keyed by theme id; cleared on every reload so
    /// scrolling never re-decodes JPEG data row by row.
    private let thumbnailCache = NSCache<NSManagedObjectID, UIImage>()

    // MARK: - Init

    init(style: UITableView.Style, viewModel: ThemeListViewModel) {
        self.viewModel = viewModel
        super.init(style: style)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

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
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (vc: ThemeListViewController, _) in
            vc.updateLogo()
            vc.navigationController?.navigationBar.putShadow()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyThemedNavigationBarStyle()
        // A theme's cover may have been edited while we were on another screen; drop the
        // decoded thumbnails so the visible rows re-read the latest image data.
        thumbnailCache.removeAllObjects()
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onViewDidAppear?()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateRowHeightIfNeeded()
    }

    // MARK: - Setup

    private func configureNavBar() {
        settingsButton.image = UIImage(systemName: "gearshape.2.fill")
        settingsButton.target = self
        settingsButton.action = #selector(didTapSettings)
        analyticsButton.image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill")
        analyticsButton.target = self
        analyticsButton.action = #selector(didTapAnalytics)
        smartGButton.image = UIImage(systemName: "number.circle.fill")
        smartGButton.target = self
        smartGButton.action = #selector(didTapSmartG)

        navigationController?.navigationBar.putShadow()
        navigationItem.leftBarButtonItem = settingsButton
        navigationItem.rightBarButtonItems = [analyticsButton, smartGButton]
        updateLogo()
    }

    private func configureTableView() {
        tableView.backgroundColor = .colorBkgd
        tableView.register(ThemeCell.self)
        addLongPressToTableView()
    }

    private func updateLogo() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
    }

    private func addFloatingButton() {
        let button = FloatingButtonFactory.createFloatingButton(onView: view)
        button.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
    }

    // MARK: - Reorder gesture

    private func addLongPressToTableView() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
        longPress.minimumPressDuration = Constants.reorderPressDuration
        tableView.addGestureRecognizer(longPress)
    }

    @objc private func onLongPressGesture(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        tableView.isEditing = true
        setEditing(true, animated: false)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // MARK: - Row height

    private func cellHeight(topInset: CGFloat) -> CGFloat {
        let screenHeight = view.frame.height
        let height = (screenHeight - Constants.tableViewBottomPadding - topInset) / Constants.rowsPerScreen
        if height <= Constants.rowMinimumHeight {
            return (screenHeight - topInset) / Constants.rowsPerScreenCompact
        }
        return height
    }

    private func updateRowHeightIfNeeded() {
        let newHeight = cellHeight(topInset: view.safeAreaInsets.top)
        if newHeight > 0, tableView.rowHeight != newHeight {
            tableView.rowHeight = newHeight
            tableView.reloadData()
        }
    }

    // MARK: - Cells

    private func makeCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ThemeCell.self, for: indexPath)
        guard let row = viewModel.themeRow(at: indexPath.row) else { return cell }
        cell.nameLabel.text = row.name
        cell.themeImageView.image = decodedThumbnail(for: row)
        // VoiceOver reads the theme name and announces the row as a navigable button;
        // the cover image is decorative (hidden from a11y inside the cell).
        cell.accessibilityLabel = row.name
        cell.accessibilityTraits = .button
        return cell
    }

    private func decodedThumbnail(for row: ThemeListViewModel.ThemeRow) -> UIImage? {
        if let cached = thumbnailCache.object(forKey: row.id) { return cached }
        guard let data = row.thumbnail, let image = UIImage(data: data) else { return nil }
        thumbnailCache.setObject(image, forKey: row.id)
        return image
    }

    // MARK: - Editing

    private func presentDeletionSafeAlert(indexPath: IndexPath) {
        let deleteAction = UIAlertAction(title: Strings.yes, style: .default) { [weak self] _ in
            self?.viewModel.deleteTheme(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .none)
        }
        let cancelAction = UIAlertAction(title: Strings.cancel, style: .cancel)
        AlertPresenter.show(
            from: self,
            title: "",
            message: Strings.deleteConfirmationMessage,
            actions: [deleteAction, cancelAction],
            preferred: cancelAction)
    }

    private func updateEditButton() {
        navigationItem.leftBarButtonItems = isEditing ? [settingsButton, editButtonItem] : [settingsButton]
    }

    // MARK: - Navigation bar actions

    @objc private func didTapCreate() { viewModel.createTheme() }
    @objc private func didTapSettings() { viewModel.openSettings() }
    @objc private func didTapAnalytics() { viewModel.openAnalytics() }
    @objc private func didTapSmartG() { viewModel.openSmartG() }
}

// MARK: - Table view data source & delegate

extension ThemeListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.themeCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        makeCell(at: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // pushViewController updates the stack synchronously, so a second fast
        // tap fails this guard instead of pushing the screen twice.
        guard navigationController?.topViewController === self else { return }
        viewModel.selectTheme(at: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presentDeletionSafeAlert(indexPath: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool { false }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        tableView.isEditing ? .none : .delete
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.reorderTheme(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        updateEditButton()
    }
}
