import SwiftUI

struct ColorfulBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(Color.mphEnd, Color.mphStart))
                    .overlay(shape.stroke(LinearGradient(Color("Color4"), Color("Color1")), lineWidth: 4))
                    .shadow(color: Color.mphStart, radius: 10, x: 5, y: 5)
                    .shadow(color: Color.mphEnd, radius: 10, x: -5, y: -5)
            } else {
                shape
                    .fill(LinearGradient(Color.mphStart, Color.mphEnd))
                    .overlay(shape.stroke(Color("Color-Bkgd"), lineWidth: 4))
                    .shadow(color: Color.mphStart, radius: 10, x: -10, y: -10)
                    .shadow(color: Color.mphEnd, radius: 10, x: 10, y: 10)
            }
        }
        .padding(5)
    }
}
