import UIKit

/// Presents the photo library and hands back the picked image with its
/// orientation normalized. Owns the `UIImagePickerController` delegate so
/// the host controller doesn't have to.
final class ThemeImagePicker: NSObject {

    private var completion: ((UIImage) -> Void)?

    func present(from presenter: UIViewController, completion: @escaping (UIImage) -> Void) {
        self.completion = completion
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        presenter.present(picker, animated: true)
    }
}

extension ThemeImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        defer {
            picker.dismiss(animated: true)
            completion = nil
        }
        guard let image = info[.originalImage] as? UIImage else {
            AppLogger.ui.error("Image picker returned no usable image (keys: \(info.keys.map(\.rawValue), privacy: .public)).")
            return
        }
        completion?(image.upOrientationImage() ?? image)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        completion = nil
    }
}
