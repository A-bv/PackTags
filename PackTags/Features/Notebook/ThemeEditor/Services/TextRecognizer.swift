import UIKit
import Vision

enum TextRecognizer {
    /// Recognizes text in `image` off the main thread. Returns an empty
    /// string when nothing could be recognized, so callers can reliably
    /// stop progress UI.
    static func recognizeText(image: UIImage?) async -> String {
        guard let cgImage = image?.cgImage else {
            AppLogger.ui.error("Text recognition needs a CGImage-backed image.")
            return ""
        }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                let request = VNRecognizeTextRequest()

                do {
                    try handler.perform([request])
                } catch {
                    AppLogger.ui.error("Text recognition failed: \(error.localizedDescription, privacy: .private)")
                    continuation.resume(returning: "")
                    return
                }

                let text = (request.results ?? [])
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: " ")
                continuation.resume(returning: text)
            }
        }
    }
}
