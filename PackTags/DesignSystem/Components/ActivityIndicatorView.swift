import SwiftUI

struct ActivityIndicatorView: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            RotatingDotsIndicatorView()
        }
    }
}
