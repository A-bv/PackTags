import SwiftUI

extension Shape {
    func outerNeumorphism<S: ShapeStyle>(_ fillContent: S) -> some View {
        self.fill(fillContent)
            .shadow(color: Color.lowerShadow, radius: 10, x: 10, y: 10)
            .shadow(color: Color.upperShadow, radius: 10, x: -5, y: -5)
    }
}
