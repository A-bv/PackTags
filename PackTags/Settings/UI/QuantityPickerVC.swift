//
//  QuantityPickerVC.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 31/03/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

var numTagsInPack: Int = {
    let savedTagQuantity = UserDefaults.standard.integer(forKey: "QuantityOfTagsPerPack")
    return savedTagQuantity == 0 ? 30 : savedTagQuantity
}()

class QuantityPickerVC: UIViewController {
    
    deinit {
        print("deinit")
    }
    
    private enum Constants {
        static let maximumTagNumber = 30
        static let minimumTagNumber = 5
        static let defaultTagNumber = 0
        static let savedTagQuantity = UserDefaults.standard.integer(forKey: "QuantityOfTagsPerPack")
        static let pickerNumberOfComponents = 1
    }
    
    private var dataArray = Array(
        (Constants.minimumTagNumber...Constants.maximumTagNumber).reversed())
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI ()
    }
    
    private func setupUI () {
        self.view.applyBlur()
        self.placeTopRightButton (arrowButton: false)
        
        let UIPicker: UIPickerView = UIPickerView()
        UIPicker.delegate = self as UIPickerViewDelegate
        UIPicker.dataSource = self as UIPickerViewDataSource
        UIPicker.center = self.view.center
        UIPicker.selectRow(
            abs(numTagsInPack - Constants.maximumTagNumber),
            inComponent: 0,
            animated: false)
        self.view.addSubview(UIPicker)
    }
}

extension QuantityPickerVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        Constants.pickerNumberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        dataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let row = String(dataArray[row])
        return row
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let row = Int(dataArray[row])
        UserDefaults.standard.set(row, forKey: "QuantityOfTagsPerPack")
        numTagsInPack = Constants.savedTagQuantity
    }
}
