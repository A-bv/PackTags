import SwiftUI

struct RoundedShape : Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft,.topRight],
            cornerRadii: CGSize(width: 5, height: 5))
        return Path(path.cgPath)
    }
}
