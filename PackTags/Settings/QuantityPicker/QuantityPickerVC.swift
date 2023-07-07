//
//  QuantityPickerVC.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 31/03/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class QuantityPickerVC: UIViewController {
    deinit {
        print("deinit QuantityPickerVC")
    }
    
    private enum Constants {
        static let pickerNumberOfComponents = 1
        static let row30 = 0
    }

    private var viewModel = QuantityPickerViewModel()
    private var numTagsInPack: Int {
        return viewModel.numTagsInPack
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        self.view.applyBlur()
        self.placeTopRightButton(arrowButton: false)
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.center = self.view.center
        
        let defaultRowIndex = viewModel.dataArray.firstIndex(of: numTagsInPack) ?? Constants.row30
        pickerView.selectRow(defaultRowIndex, inComponent: 0, animated: false)
        self.view.addSubview(pickerView)
    }
}

extension QuantityPickerVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        Constants.pickerNumberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.dataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let row = String(viewModel.dataArray[row])
        return row
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedRow = viewModel.dataArray[row]
        viewModel.numTagsInPack = selectedRow
    }
}
