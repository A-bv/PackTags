import SwiftUI

struct ActivityIndicatorView: View {

    enum IndicatorType {
        case rotatingDots
    }

    @Binding var isVisible: Bool
    var type: IndicatorType

    init(isVisible: Binding<Bool>, type: IndicatorType) {
        self._isVisible = isVisible
        self.type = type
    }

    var body: some View {
        guard isVisible else { return AnyView(EmptyView()) }
        return AnyView(RotatingDotsIndicatorView())
    }
}
