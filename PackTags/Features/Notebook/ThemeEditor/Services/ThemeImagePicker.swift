import PhotosUI
import UIKit

/// Presents the photo library and hands back the picked image with its
/// orientation normalized. Owns the `PHPickerViewController` delegate so
/// the host controller doesn't have to. The picker runs out of process,
/// so no photo-library permission is required.
///
/// Loading the picked image is asynchronous and can take a moment (large or
/// iCloud-backed photos), so a loading overlay is shown over the presenter
/// during that gap — otherwise the screen sits blank after the picker dismisses.
@MainActor
final class ThemeImagePicker: NSObject {

    private var completion: ((UIImage) -> Void)?
    private weak var presenter: UIViewController?

    private lazy var loadingOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        overlay.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
        ])
        return overlay
    }()

    func present(from presenter: UIViewController, completion: @escaping (UIImage) -> Void) {
        self.presenter = presenter
        self.completion = completion
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        presenter.present(picker, animated: true)
    }

    /// Blocks interaction and shows a spinner over the presenter while the
    /// picked image loads.
    private func showLoading() {
        guard let view = presenter?.view else { return }
        view.addSubview(loadingOverlay)
        NSLayoutConstraint.activate([
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func hideLoading() {
        loadingOverlay.removeFromSuperview()
    }
}

extension ThemeImagePicker: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider else { // Cancelled
            completion = nil
            return
        }
        guard provider.canLoadObject(ofClass: UIImage.self) else {
            AppLogger.ui.error("Photo picker selection cannot be loaded as an image (types: \(provider.registeredTypeIdentifiers, privacy: .public)).")
            completion = nil
            return
        }
        showLoading()
        provider.loadObject(ofClass: UIImage.self) { object, error in
            let image = object as? UIImage
            Task { @MainActor [weak self] in
                defer {
                    self?.hideLoading()
                    self?.completion = nil
                }
                guard let image else {
                    AppLogger.ui.error("Photo picker failed to load the image: \(String(describing: error), privacy: .private).")
                    return
                }
                self?.completion?(image.upOrientationImage() ?? image)
            }
        }
    }
}
