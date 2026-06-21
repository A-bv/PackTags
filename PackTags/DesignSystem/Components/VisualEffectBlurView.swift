import SwiftUI

/// A `UIVisualEffectView` blur for use as a SwiftUI background. The host controller's
/// view must be transparent for the content behind to blur through.
struct VisualEffectBlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemThinMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
