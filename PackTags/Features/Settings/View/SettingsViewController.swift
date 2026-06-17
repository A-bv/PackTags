import UIKit
import SafariServices
import MessageUI

final class SettingsViewController: UIViewController {
    private enum Strings {
        static let settingsTitle = "Settings".localized()
        // Alert title. Deliberately not shared with the catalog's "Instagram" row label
        // (SettingsSections) — coincidentally the same word, but a different role.
        static let instagram = "Instagram".localized()
        static let rateAndReviewYourFeedback = "Your feedback".localized()
        static let rateAndReviewEnjoyingQuestion = "Are you enjoying PackTags?".localized()
        static let rateAndReviewDismiss = "Dismiss".localized()
        static let rateAndReviewRateUsOnAppStore = "Yes! Rate us on the App Store.".localized()
        static let rateAndReviewTellUsWhyQuestion = "No! Tell us why.".localized()
        static let mailRecipient = "packtagsapp@gmail.com"
    }

    let viewModel: SettingsViewModel

    private let tableView = UITableView(frame: .zero, style: .grouped)

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.putShadow(false)
        tableView.backgroundColor = .colorBkgd
        title = Strings.settingsTitle
        tableView.register(SettingsCell.self)
        tableView.register(SettingsSwitchCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        viewModel.onViewEvent = { [weak self] event in self?.handle(event) }
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }

    private func handle(_ event: SettingsViewModel.ViewEvent) {
        switch event {
        case let .editInstagram(message, placeholder):
            presentInstagramAlert(message: message, placeholder: placeholder)
        case let .shareApp(url):
            presentShareSheet(for: url)
        case let .rateApp(writeReviewURL):
            presentReviewPrompt(writeReviewURL: writeReviewURL)
        case let .openWebPage(url):
            presentWebPage(url)
        case .contactSupport:
            sendSupportEmail()
        case let .openExternalApp(appURL, webURL):
            ExternalLinkOpener.openAppURL(appURL: appURL, webURL: webURL)
        }
    }

    private func presentWebPage(_ url: URL) {
        let safari = SFSafariViewController(url: url)
        safari.modalPresentationStyle = .overFullScreen
        safari.modalTransitionStyle = .crossDissolve
        present(safari, animated: true)
    }
}

// MARK: - Presentation

private extension SettingsViewController {
    func presentInstagramAlert(message: String, placeholder: String) {
        Alerts.showTextInputAlert(
            from: self,
            title: Strings.instagram,
            message: message,
            placeholder: placeholder
        ) { [weak self] inputName in
            self?.viewModel.saveInstagramUsername(inputName)
        }
    }

    func presentReviewPrompt(writeReviewURL: URL) {
        let dismiss = UIAlertAction(title: Strings.rateAndReviewDismiss, style: .cancel)
        let rate = UIAlertAction(title: Strings.rateAndReviewRateUsOnAppStore, style: .default) { _ in
            UIApplication.shared.open(writeReviewURL)
        }
        let tellUsWhy = UIAlertAction(title: Strings.rateAndReviewTellUsWhyQuestion, style: .default) { [weak self] _ in
            self?.sendSupportEmail()
        }
        Alerts.show(
            from: self,
            title: Strings.rateAndReviewYourFeedback,
            message: Strings.rateAndReviewEnjoyingQuestion,
            actions: [dismiss, rate, tellUsWhy])
    }

    func presentShareSheet(for url: URL) {
        let activityViewController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil)

        // For iPad, anchor the popover to the screen centre.
        if UIDevice.current.userInterfaceIdiom == .pad {
            let popover = activityViewController.popoverPresentationController
            popover?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
            popover?.sourceView = view
            popover?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }

        present(activityViewController, animated: true)
    }

    func sendSupportEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            AppLogger.ui.info("No email account configured on this device.")
            return
        }
        let mail = MFMailComposeViewController()
        mail.modalPresentationStyle = .overFullScreen
        mail.mailComposeDelegate = self
        mail.setToRecipients([Strings.mailRecipient])
        present(mail, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].options.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.sections[indexPath.section].options[indexPath.row] {
        case .staticCell(let option):
            let cell = tableView.dequeue(SettingsCell.self, for: indexPath)
            cell.configure(with: option)
            cell.backgroundColor = .systemBackground
            return cell
        case .switchCell(let option):
            let cell = tableView.dequeue(SettingsSwitchCell.self, for: indexPath)
            cell.configure(with: option)
            cell.backgroundColor = .systemBackground
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

// MARK: - MFMailComposeViewControllerDelegate

extension SettingsViewController: @preconcurrency MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
