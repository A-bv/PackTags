//
//  ViewController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.09.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension ThemeVC {
    func setImagePicker () {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerControllerDelegate
extension ThemeVC {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any])
    {
        guard let selectedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage
        else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Regular action
        if recognizeText == false {
            
            DispatchQueue.main.async { [weak self] in
                self?.themeImageView = selectedImage.upOrientationImage()
            
                //Downsampling
                self?.themeImageView  = selectedImage.resized(to: CGSize(width: 600,height: 600))
            }
            
            
        //Text Recognition (2/2)
        } else {
            spinner.startAnimating()
            DispatchQueue.main.async {
                let tempImageForRecon = selectedImage.upOrientationImage()
                self.themeTextView.hidePlaceholder()
                
                self.recognizeText(image: tempImageForRecon!)
                { [weak self] (text) in
                    if let initialText = self?.themeTextView.text {
                        self?.themeTextView.text = text + "\n\n" + initialText
                    } else {
                        self?.themeTextView.text = text
                    }
                }
                self.spinner.stopAnimating()
                self.recognizeText = false
            }
        }
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil) // Dismiss the picker
    }
}
