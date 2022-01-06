//
//  QuantityPickerVC.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 31/03/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class QuantityPickerVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    deinit {
        print("deinit")
    }
    
    var dataArray = Array((5...30).reversed())
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.applyBlur()
        self.modalUI (arrowButton: false)
        
        let UIPicker: UIPickerView = UIPickerView()
        UIPicker.delegate = self as UIPickerViewDelegate
        UIPicker.dataSource = self as UIPickerViewDataSource
        UIPicker.center = self.view.center
        UIPicker.selectRow(abs(numTagsInPack - 30),inComponent: 0,animated: false)
        self.view.addSubview(UIPicker)
        
        /*
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width , height: 40))
        label.text = "A quantity of 30 is recommended"
        label.textAlignment = .center
        self.view.addSubview(label)
        */
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return dataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        let row = String(dataArray[row])
        return row
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UserDefaults.standard.set(Int(dataArray[row]), forKey: "QuantityOfTagsPerPack")
        numTagsInPack = UserDefaults.standard.integer(forKey: "QuantityOfTagsPerPack")
    }
}

public var numTagsInPack: Int = UserDefaults.standard.integer(forKey: "QuantityOfTagsPerPack") == 0 ? 30 : UserDefaults.standard.integer(forKey: "QuantityOfTagsPerPack")




