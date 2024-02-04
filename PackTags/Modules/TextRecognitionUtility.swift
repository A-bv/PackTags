//
//  Image_Recon.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09/10/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import Vision

final class TextRecognitionUtility {
    static func recognizeText(
        image: UIImage?,
        returnCompletion: @escaping (String) -> ()
    ) {

        guard let cgImage = image?.cgImage else {
            fatalError("Could not get cgImage")
        }

        // Handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        // Request
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                return
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
            print("\(error)")
        }
    }
}
