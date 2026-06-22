import SwiftUI

struct LoadingView: View {
    @Binding var loading: Bool
    private enum Constants {
        static let loadingIndicatorFrame: CGFloat = 70
        static let indicatorColor: Color = .brandPurple
    }

    var body: some View {
        ZStack {
            Color.bgFillColor
                .edgesIgnoringSafeArea(.all)

            if loading {
                RotatingDotsIndicatorView()
                    .foregroundColor(Constants.indicatorColor)
                    .frame(
                        width: Constants.loadingIndicatorFrame,
                        height: Constants.loadingIndicatorFrame,
                        alignment: .center)
            }
        }
    }
}

#Preview {
    LoadingView(loading: .constant(true))
}
