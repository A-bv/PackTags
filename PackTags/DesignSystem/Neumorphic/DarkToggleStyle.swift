import SwiftUI

struct DarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            configuration.label
                .padding(10)
                .contentShape(Circle())
        }
        .background(
            ColorfulBackgroundView(
                isHighlighted: configuration.isOn,
                shape: RoundedRectangle(cornerRadius: 10))
        )
    }
}
