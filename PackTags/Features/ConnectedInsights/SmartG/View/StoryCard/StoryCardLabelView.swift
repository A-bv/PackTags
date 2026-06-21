import SwiftUI

struct StoryCardLabelView: View {
    private enum Constants {
        static let cardLabelFontSize: CGFloat = 12
    }

    let comments: String
    let likes: String
    let hashtagsCount: String

    var body: some View {
        HStack {
            label(icon: "text.bubble.fill", count: comments)
            label(icon: "suit.heart.fill", count: likes)
            label(icon: "number.circle.fill", count: hashtagsCount)
        }
        .foregroundColor(.white)
        .background(Color.clear)
    }

    @ViewBuilder
    private func label(icon: String, count: String) -> some View {
        if count != "0" {
            Image(systemName: icon)
            Text(count)
                .font(.system(size: Constants.cardLabelFontSize, weight: .semibold))
        }
    }
}
