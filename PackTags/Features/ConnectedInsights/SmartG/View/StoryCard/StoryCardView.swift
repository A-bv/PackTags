import SwiftUI

struct StoryCardView: View {
    private enum Strings {
        static let loading3Dots = "Loading...".localized()
    }

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
        CachedAsyncImage(url: url) {
            Text(Strings.loading3Dots)
        }
    }
}

#Preview {
    StoryCardView(
        url: URL(string: "https://picsum.photos/300/500")!,
        comments: "12",
        likes: "340",
        hashtagsCount: "8",
        cardWidth: 250,
        cardHeight: 400,
        cardCornerRadius: 20)
}
