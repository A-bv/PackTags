import SwiftUI

// TODO: Get rid of it?
struct MonoCircleView: View {
    private enum Constants {
        static let padding: CGFloat = 50
        static let textColor: Color = Color("Color4")
    }
    
    let monoCircleValue: Double
    let rawInsights: Bool
    
    var body: some View {
        VStack {
            let value = StringFormatter.formatNum(value: monoCircleValue)
            let text = getText(for: value)
            
            Text(text)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Constants.textColor)
        }
        .padding(2 * Constants.padding)
        .background(
            Circle()
                .outerNeumorphism(Color.statsFillColor)
        )
    }
    
    private func getText(for value: String) -> String {
        if rawInsights {
            return Double(monoCircleValue) <= 100 ? value.components(separatedBy: ".")[0] : value
        } else {
            return rawInsights ? value : value + " %"
        }
    }
}

struct MonoCircleView_Previews: PreviewProvider {
    static var previews: some View {
        MonoCircleView(monoCircleValue: 12, rawInsights: true)
    }
}
