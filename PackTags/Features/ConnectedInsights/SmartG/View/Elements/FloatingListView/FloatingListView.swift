import SwiftUI

private enum Constants {
    static let numberOfTags = 10
    static let tagSpacing: CGFloat = 30
    static let tagListHeight: CGFloat = 330
    static let tagListPadding: CGFloat = 20
    static let tagColor = Color("Color4").opacity(0.7)
    static let tagPadding: CGFloat = 10
    static let tagCornerRadius: CGFloat = 10
}

struct FloatingListView: View {
    let viewModel: SmartGViewModel
    @State private var childSizes = [CGSize](repeating: .zero, count: Constants.numberOfTags)
    @State private var tagYPos = [CGFloat](repeating: .zero, count: Constants.numberOfTags)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                ForEach(Array(viewModel.topHashtags.enumerated()), id: \.element) { index, item in
                    let padding = Constants.tagPadding + Constants.tagListPadding
                    let maxX = geometry.size.width/2 - childSizes[index].width/2 - padding
                    let x = CGFloat.random(in: -maxX...maxX)

                    TagView(
                        color: Constants.tagColor,
                        index: index,
                        item: item,
                        childSizes: $childSizes,
                        x: x,
                        y: tagYPos[index],
                        tagPadding: Constants.tagPadding,
                        tagCornerRadius: Constants.tagCornerRadius)
                }
            }
            .frame(width: geometry.size.width - 2 * Constants.tagListPadding, height: Constants.tagListHeight)
            .padding(.horizontal, Constants.tagListPadding)
        }
        .frame(height: Constants.tagListHeight)
        .onAppear {
            tagYPos = generateTagYPos()
        }
    }
    
    private func generateTagYPos() -> [CGFloat] {
        let initial = -Constants.tagListHeight/2 + Constants.tagListPadding + Constants.tagCornerRadius
        let final = CGFloat(Constants.numberOfTags) * Constants.tagSpacing
        return Array(stride(from: initial, through: final, by: Constants.tagSpacing))
    }
}

struct FloatingListView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingListView(viewModel: SmartGViewModel(gateway: UnavailableConnectedInsightsGateway()))
    }
}
