import SwiftUI

struct RotatingDotsIndicatorView: View {

    private let count: Int = 5

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<self.count, id: \.self) { index in
                RotatingDotsIndicatorItemView(index: index, size: geometry.size)
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    RotatingDotsIndicatorView()
        .frame(width: 70, height: 70)
        .foregroundColor(.brandPurple)
}
