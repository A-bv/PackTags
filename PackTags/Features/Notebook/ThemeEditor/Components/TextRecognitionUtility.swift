import UIKit
import Vision

final class TextRecognitionUtility {
    /// Recognizes text in `image` off the main thread. The completion is
    /// always called on the main thread — with an empty string when nothing
    /// could be recognized — so callers can reliably stop progress UI.
    static func recognizeText(
        image: UIImage?,
        returnCompletion: @escaping (String) -> ()
    ) {
        guard let cgImage = image?.cgImage else {
            AppLogger.ui.error("Text recognition needs a CGImage-backed image.")
            DispatchQueue.main.async { returnCompletion("") }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            // Handler
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            // Request
            let request = VNRecognizeTextRequest { request, error in
                let observations = (request.results as? [VNRecognizedTextObservation]) ?? []
                if let error {
                    AppLogger.ui.error("Text recognition failed: \(error.localizedDescription, privacy: .public)")
                }

                let text = observations.compactMap({
                    $0.topCandidates(1).first?.string
                }).joined(separator: " ")

                DispatchQueue.main.async {
                    returnCompletion(text)
                }
            }

            // Process request
            do {
                try handler.perform([request])
            } catch {
                AppLogger.ui.error("Text recognition failed: \(error.localizedDescription, privacy: .public)")
                DispatchQueue.main.async { returnCompletion("") }
            }
        }
    }
}
