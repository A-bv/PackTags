import SwiftUI
import InstagramGraph

private enum Constants {
    static let cardWidth: CGFloat = 190
    static let cardHeight: CGFloat = 220
    static let cardCornerRadius: CGFloat = 12
}

extension CollectionView {
    func makeStoryCards() -> some View {
        let medias = Array(viewModel.dataMedias.enumerated())
        
        return ForEach(medias, id: \.element) { index, media in
            makeStoryCard(from: media, index: index)
        }
    }

    private func makeStoryCard(from media: InstagramPost, index: Int) -> some View {
        guard
            let url = media.mediaUrl,
            let likeCount = media.likeCount,
            let commentsCount = media.commentsCount
        else {
            return AnyView(EmptyView())
        }

        let likes = StringFormatter.formatNum(
            value: Double(likeCount),
            noDecimal: true
        )

        let hashtagsCount: String
        if viewModel.computedData.indices.contains(index) {
            hashtagsCount = String(viewModel.computedData[index].hashtags.count)
        } else {
            hashtagsCount = "0"
        }

        return AnyView(
            StoryCard(
                url: url,
                comments: String(commentsCount),
                likes: likes,
                hashtagsCount: hashtagsCount,
                cardWidth: Constants.cardWidth,
                cardHeight: Constants.cardHeight,
                cardCornerRadius: Constants.cardCornerRadius)
        )
    }
}
