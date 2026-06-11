import SwiftUI

private enum Constants {
    static let numberOfTags = 10
    static let tagSpacing: CGFloat = 30
    static let tagListWidth = UIScreen.main.bounds.width - 40
    static let tagListHeight: CGFloat = 330
    static let tagListPadding: CGFloat = 20
    static let tagListCornerRadius: CGFloat = 20
    static let tagSize: CGFloat = 50
    static let tagColor = Color("Color4").opacity(0.7)
    static let tagDefaultColor = Color.black.opacity(0.7)
    static let screenWidth = UIScreen.main.bounds.width
    static let tagPadding: CGFloat = 10
    static let tagCornerRadius: CGFloat = 10
}

struct FloatingListView: View {
    @ObservedObject var viewModel: SmartGViewModel
    @State private var hashtagEntry: String = "Tag entry"
    @State private var childSizes = [CGSize](repeating: .zero, count: Constants.numberOfTags)
    @State private var tagYPos = [CGFloat](repeating: .zero, count: Constants.numberOfTags)
    @State private var topTags: [String] = []

    var body: some View {
        ZStack{
            VStack() {
                rHashtagsList
            }
        }
    }
    
    var rHashtagsList: some View {
        ZStack {
            Color.clear
            // if !topTags.isEmpty {
                ForEach(Array(viewModel.topHashtags.enumerated()), id: \.element) { index, item in
                    let padding = Constants.tagPadding + Constants.tagListPadding
                    let maxX = Constants.screenWidth/2 - childSizes[index].width/2 - padding
                    let x = CGFloat.random(in: -maxX...maxX)
                    let y = tagYPos[index]
                    
                    let color = Constants.tagColor

                    TagView(
                        color: color,
                        index: index,
                        item: item,
                        childSizes: $childSizes,
                        hashtagsL: $topTags,
                        x: x,
                        y: y,
                        tagPadding: Constants.tagPadding,
                        tagCornerRadius: Constants.tagCornerRadius)
                }
            // }
        }
        .frame(width: Constants.tagListWidth, height: Constants.tagListHeight)
        // .cornerRadius(Constants.tagListCornerRadius)
        .padding(.horizontal, Constants.tagListPadding)
        .onAppear(perform: {
            tagYPos = generateTagYPos()
        })
    }
    
    func generateTagYPos() -> [CGFloat] {
        let initial = -Constants.tagListHeight/2 + Constants.tagListPadding + Constants.tagCornerRadius
        let final = CGFloat(Constants.numberOfTags) * Constants.tagSpacing
        return Array(stride(from: initial, through: final, by: Constants.tagSpacing))
    }
}

struct FloatingListView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingListView(viewModel: SmartGViewModel())
    }
}
