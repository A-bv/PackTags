import Testing
import UIKit
@testable import PackTags

@MainActor
@Suite struct SettingsAccessibilityTests {

    @Test func settingsCell_readsAsAButtonLabeledWithItsTitle() {
        let cell = SettingsCell(style: .default, reuseIdentifier: nil)

        cell.configure(with: SettingsOptionModel(
            title: "Manage", iconBackgroundColor: .systemBlue, handler: {}))

        #expect(cell.isAccessibilityElement)
        #expect(cell.accessibilityLabel == "Manage")
        #expect(cell.accessibilityTraits.contains(.button))
    }

    @Test func settingsSwitchCell_exposesTheSwitchNamedByItsTitle() {
        let cell = SettingsSwitchCell(style: .default, reuseIdentifier: nil)

        cell.configure(with: SettingsSwitchOptionModel(
            title: "Save & shuffle", iconBackgroundColor: .systemGreen, isOn: true, onToggle: { _ in }))

        // The cell defers to the switch, which now says what it toggles.
        #expect(cell.isAccessibilityElement == false)
        let element = cell.accessibilityElements?.first as? UISwitch
        #expect(element?.accessibilityLabel == "Save & shuffle")
        #expect(element?.isOn == true)
    }
}
