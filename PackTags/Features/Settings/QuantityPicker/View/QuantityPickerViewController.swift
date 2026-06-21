import UIKit

final class QuantityPickerViewController: UIViewController {
    private enum Constants {
        static let pickerNumberOfComponents = 1
        static let defaultRowIndex = 0
        static let pickerValues = Array((5...30).reversed())
    }

    private let appSettings: any AppSettingsProtocol

    init(appSettings: any AppSettingsProtocol) {
        self.appSettings = appSettings
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        self.view.applyBlur()
        addModalCloseButton()
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.center = self.view.center
        
        let selectedRowIndex = Constants.pickerValues.firstIndex(of: appSettings.tagsPerPack) ?? Constants.defaultRowIndex
        pickerView.selectRow(selectedRowIndex, inComponent: 0, animated: false)
        self.view.addSubview(pickerView)
    }
}

extension QuantityPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        Constants.pickerNumberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Constants.pickerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        String(Constants.pickerValues[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        appSettings.tagsPerPack = Constants.pickerValues[row]
    }
}
