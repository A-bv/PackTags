//
//  ThemeEditorViewController+ImgPicker.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.09.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension ThemeEditorViewController: UIImagePickerControllerDelegate {
    private enum Constants {
        static let imageSize = 600
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            AppLogger.ui.error("Image picker returned no usable image (keys: \(info.keys.map(\.rawValue), privacy: .public)).")
            picker.dismiss(animated: true, completion: nil)
            return
        }

        if !recognizeText {
            handleRegularImageSelection(image)
        } else {
            handleTextRecognitionImageSelection(image)
        }

        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func setImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension ThemeEditorViewController {
    private func handleRegularImageSelection(_ image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.themeImageView = image.upOrientationImage()
            
            let imageSize = CGSize(width: Constants.imageSize, height: Constants.imageSize)
            self.themeImageView = image.resized(to: imageSize)
        }
    }
    
    private func handleTextRecognitionImageSelection(_ image: UIImage) {
        spinner.startAnimating()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let tempImageForRecon = image.upOrientationImage()
            self.themeTextView.hidePlaceholder()
            
            TextRecognitionUtility.recognizeText(image: tempImageForRecon) { [weak self] text in
                guard let self = self else { return }
                
                if let initialText = self.themeTextView.text {
                    self.themeTextView.text = text + "\n\n" + initialText
                } else {
                    self.themeTextView.text = text
                }
            }
            
            self.spinner.stopAnimating()
            self.recognizeText = false
        }
    }
}
