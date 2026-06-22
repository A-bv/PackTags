import SwiftUI
import NeumorphicSwiftUI

struct MonoCircleView: View {
    private enum Constants {
        static let padding: CGFloat = 50
        static let textColor: Color = Color("Color4")
        static let circlePaddingRadius: CGFloat = 100
    }
    
    let monoCircleValue: Double
    let isRate: Bool
    
    var body: some View {
        VStack {
            let text = MetricFormatter.text(for: monoCircleValue, isRate: isRate)
            Text(text)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Constants.textColor)
        }
        .padding(Constants.circlePaddingRadius)
        .background(
            Circle()
                .fill(Color.statsFillColor).neumorphicShadow()
        )
    }
}

#Preview {
    MonoCircleView(monoCircleValue: 12.1, isRate: false)
}
