//
//  ViewController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.09.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension ThemeVC: UIImagePickerControllerDelegate {
    private enum Constants {
        static let imageSize = 600
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
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

extension ThemeVC {
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
