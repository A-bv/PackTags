import UIKit

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
    private enum Strings {
        static let oneHashtag = "1 Hashtag".localized()
        static let more = "more".localized()
        static let zeroHashtags = "0 Hashtags".localized()
        static let tapPencil = "Tap the Pencil button to add Hashtags.".localized()
        static let show = "Show".localized()
    }

    func configureCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PackCell", for: indexPath) as? PackCell
        else {
            fatalError("The dequeued cell is not an instance of PackCell.")
        }

        let pack = self.packs[indexPath.row]
        let row = viewModel.packRow(at: indexPath.row)

        cell.cellLabel.text = row?.firstTag
        let badge: String
        switch row?.tagCount ?? 0 {
        case 0: badge = " \(Strings.zeroHashtags) "
        case 1: badge = " \(Strings.oneHashtag) "
        case let count: badge = " + \(count - 1) \(Strings.more) "
        }
        cell.subButton.setTitle(badge, for: .normal)

        cell.buttonTapCallback = { [weak self] in
            self?.pasteboard.string = pack
            self?.goInsta(packIdx: indexPath.row)
        }

        cell.subButtonTapCallback = { [weak self] in
            let message = pack.isEmpty ? Strings.tapPencil : pack
            self?.subBtnAlert(title: "", message: message)
        }

        if indexPath.row == 0 {
            cell.roundTopCorners(radius: cR)
        }

        return cell
    }

    func addSCellSwipeAccessory(indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
