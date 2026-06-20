import SwiftUI

struct LoadingView: View {
    @Binding var loading: Bool
    private enum Constants {
        static let loadingIndicatorFrame: CGFloat = 70
        static let indicatorColor: Color = Color("customPurple")
    }

    var body: some View {
        ZStack {
            Color.bgFillColor
                .edgesIgnoringSafeArea(.all)

            ActivityIndicatorView(isVisible: $loading)
                .foregroundColor(Constants.indicatorColor)
                .frame(
                    width: Constants.loadingIndicatorFrame,
                    height: Constants.loadingIndicatorFrame,
                    alignment: .center)
        }
    }
}
