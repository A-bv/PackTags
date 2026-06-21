import SwiftUI

struct ColorfulButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(10)
            .contentShape(Circle())
            .background(
                ColorfulBackgroundView(
                    isHighlighted: configuration.isPressed,
                    shape: RoundedRectangle(cornerRadius: 10)))
            .animation(nil, value: configuration.isPressed)
    }
}
