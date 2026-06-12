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

    @ViewBuilder
    private func makeStoryCard(from media: InstagramPost, index: Int) -> some View {
        if let url = media.mediaUrl,
           let likeCount = media.likeCount,
           let commentsCount = media.commentsCount {
            StoryCard(
                url: url,
                comments: String(commentsCount),
                likes: StringFormatter.formatNum(value: Double(likeCount), noDecimal: true),
                hashtagsCount: hashtagsCount(at: index),
                cardWidth: Constants.cardWidth,
                cardHeight: Constants.cardHeight,
                cardCornerRadius: Constants.cardCornerRadius)
        }
    }

    private func hashtagsCount(at index: Int) -> String {
        guard viewModel.computedData.indices.contains(index) else { return "0" }
        return String(viewModel.computedData[index].hashtags.count)
    }
}
