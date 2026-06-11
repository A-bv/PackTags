import SwiftUI

// BarchartArrows
struct BarchartArrowsView: View {
    let postsCount: Int
    
    private enum Constants {
        static let opacity: CGFloat = 0.6
    }
    
    private enum Strings {
        static let previousPosts = "Previous posts".localized()
        static let previousPost = "Previous post".localized()
        static let latest = "Latest post".localized()
    }
    
    var body: some View {
        HStack {
            if postsCount != 1 {
                Image(systemName: "arrow.turn.left.up")
                    .font(.caption)
                    .foregroundColor(Color(UIColor.label).opacity(Constants.opacity))
                Text(Strings.latest)
                    .font(.caption)
                    .foregroundColor(Color(UIColor.label).opacity(Constants.opacity))
            }
            Spacer()
            
            let leftArrowText = postsCount != 1 ? Strings.previousPosts : Strings.previousPost
            // "Last \(num ?? 0) Posts" : Strings.previousPosts
            Text(leftArrowText)
                .font(.caption)
                .foregroundColor(Color(UIColor.label).opacity(Constants.opacity))
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundColor(Color(UIColor.label).opacity(Constants.opacity))
        }
    }
}

struct BarchartArrowsView_Previews: PreviewProvider {
    static var previews: some View {
        BarchartArrowsView(postsCount: 3)
            .padding()
    }
}
