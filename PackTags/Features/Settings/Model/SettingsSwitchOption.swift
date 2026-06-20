import UIKit

struct SettingsSwitchOption {
    let title: String
    let iconBackgroundColor: UIColor
    var isOn: Bool
    let onToggle: (Bool) -> Void
}
