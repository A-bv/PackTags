import PhotosUI
import UIKit

/// Presents the photo library and hands back the picked image with its
/// orientation normalized. Owns the `PHPickerViewController` delegate so
/// the host controller doesn't have to. The picker runs out of process,
/// so no photo-library permission is required.
///
/// The picker's *first* presentation spins up that out-of-process extension,
/// which briefly hangs the main thread — so a spinner is shown before
/// presenting, otherwise the screen sits frozen with no feedback after the tap.
@MainActor
final class ThemeImagePicker: NSObject {

    private var completion: ((UIImage) -> Void)?
    private weak var presenter: UIViewController?

    /// True while the loading overlay is on screen. Exposed for tests.
    private(set) var isLoading = false

    /// Presents `picker` from `presenter`, invoking `onPresented` once it's up.
    /// Injectable so tests can drive presentation synchronously. The default
    /// defers to the next run loop so the spinner paints before the picker's
    /// first-launch hitch blocks the main thread.
    var presentPicker: (_ presenter: UIViewController,
                        _ picker: UIViewController,
                        _ onPresented: @escaping () -> Void) -> Void
        = { presenter, picker, onPresented in
            DispatchQueue.main.async {
                presenter.present(picker, animated: true, completion: onPresented)
            }
        }

    private lazy var loadingOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = .colorBkgd
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

        setLoading(true)
        presentPicker(presenter, picker) { [weak self] in
            self?.setLoading(false)
        }
    }

    private func setLoading(_ loading: Bool) {
        isLoading = loading
        guard loading else {
            loadingOverlay.removeFromSuperview()
            return
        }
        guard let view = presenter?.view else { return }
        view.addSubview(loadingOverlay)
        NSLayoutConstraint.activate([
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
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
        provider.loadObject(ofClass: UIImage.self) { object, error in
            let image = object as? UIImage
            Task { @MainActor [weak self] in
                defer { self?.completion = nil }
                guard let image else {
                    AppLogger.ui.error("Photo picker failed to load the image: \(String(describing: error), privacy: .private).")
                    return
                }
                self?.completion?(image.upOrientationImage() ?? image)
            }
        }
    }
}
