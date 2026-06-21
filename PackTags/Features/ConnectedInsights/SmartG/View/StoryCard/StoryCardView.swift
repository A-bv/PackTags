import SwiftUI

private enum Strings {
    static let loading3Dots = "Loading...".localized()
}

struct StoryCardView: View {
    let url: URL
    let comments: String
    let likes: String
    let hashtagsCount: String
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let cardCornerRadius: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottom) {
            asyncImage()
                .aspectRatio(contentMode: .fill)
                .frame(width: cardWidth, height: cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
            
            StoryCardLabelView(
                comments: comments,
                likes: likes,
                hashtagsCount: hashtagsCount)
            .padding()
        }
    }
    
    private func asyncImage() -> some View {
        AsyncImage(url: url) { image in
            image.resizable()
        } placeholder: {
            Text(Strings.loading3Dots)
        }
    }
}
