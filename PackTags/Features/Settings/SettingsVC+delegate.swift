import UIKit

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = viewModel.sections[section]
        return section.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.sections[indexPath.section].options[indexPath.row]
        switch model {
        case .staticCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsCell.identifier,
                for: indexPath
            ) as? SettingsCell else {
                fatalError("The dequeued cell is not an instance of SettingsCell.")
            }
            cell.configure(with: model)
            cell.backgroundColor = UIColor.systemBackground
            return cell
        case .switchCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsSwitchCell.identifier,
                for: indexPath
            ) as? SettingsSwitchCell else {
                fatalError("The dequeued cell is not an instance of SettingsSwitchCell.")
            }
            cell.configure(with: model)
            
            cell.backgroundColor = UIColor.systemBackground
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if case .staticCell(let model) = viewModel.sections[indexPath.section].options[indexPath.row] {
            model.handler()
        }
    }
}
