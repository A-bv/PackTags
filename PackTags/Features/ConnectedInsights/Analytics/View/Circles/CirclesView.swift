import SwiftUI

struct CirclesView: View {
    @Binding var circles: [Circles]
    var isRate: Bool
    let columns: [GridItem]
    let availableWidth: CGFloat

    private enum Constants {
        static let circleTitleToCirclePadding: CGFloat = 25
        static let circleTitleFontSize: CGFloat = 20
        static let circleLineWidth: CGFloat = 10
        static let circleTrimStart: CGFloat = 0
        static let circleTrimEnd: CGFloat = 1
        static let gradientStartColor = Color("Color4")
        static let gradientEndColor = Color("Color1")
        static let valueRotationDegrees: Double = 90
        static let circleStartRotationDegrees: Double = -90
    }

    private var outerDiameter: CGFloat { (availableWidth - 130) / 2 }
    private var innerDiameter: CGFloat { (availableWidth - 150) / 2 }
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(circles) { circle in
                VStack(spacing: Constants.circleTitleToCirclePadding) {
                    HStack {
                        Text(circle.title)
                            .font(.system(size: Constants.circleTitleFontSize))
                            .foregroundColor(Color(UIColor.label))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    ZStack {
                        Circle()
                            .trim(from: Constants.circleTrimStart, to: Constants.circleTrimEnd)
                            .stroke(Color.clear, lineWidth: Constants.circleLineWidth)
                            .frame(width: outerDiameter, height: outerDiameter)
                            .background(
                                Circle()
                                    .outerNeumorphism(Color.statsFillColor)
                                    .rotationEffect(.degrees(Constants.valueRotationDegrees)))
                        
                        Circle()
                            .trim(from: Constants.circleTrimStart, to: (circle.value / circle.maxValue))
                            .stroke(
                                LinearGradient(Constants.gradientStartColor, Constants.gradientEndColor),
                                style: StrokeStyle(lineWidth: Constants.circleLineWidth, lineCap: .round))
                            .frame(width: innerDiameter, height: innerDiameter)

                        Text(
                            StringFormatter.formatValueToText(
                                with: circle.value,
                                isRate: isRate))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .rotationEffect(.init(degrees: Constants.valueRotationDegrees))
                    }
                    .rotationEffect(.init(degrees: Constants.circleStartRotationDegrees))
                }
            }
        }
    }
}

struct CirclesView_Previews: PreviewProvider {
    @State static var circles: [Circles] = [
        Circles(id: 0, title: "Average", value: 203.1, maxValue: 7),
        Circles(id: 1, title: "Selection", value: 133.3, maxValue: 80)
    ]
    
    static var previews: some View {
        let gridItem = GridItem(.flexible())
        ZStack {
            Color.bgFillColor.ignoresSafeArea()
            VStack() {
                CirclesView(
                    circles: $circles,
                    isRate: true,
                    columns: [gridItem],
                    availableWidth: 390)
            }
            .padding(50)
        }
    }
}
