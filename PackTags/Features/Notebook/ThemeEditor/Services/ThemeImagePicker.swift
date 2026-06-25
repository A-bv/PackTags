import PhotosUI
import UIKit

/// Presents the photo library and hands back the picked image with its
/// orientation normalized. Owns the `PHPickerViewController` delegate so
/// the host controller doesn't have to. The picker runs out of process,
/// so no photo-library permission is required.
@MainActor
final class ThemeImagePicker: NSObject {

    private var completion: ((UIImage) -> Void)?

    func present(from presenter: UIViewController, completion: @escaping (UIImage) -> Void) {
        self.completion = completion
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        presenter.present(picker, animated: true)
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
