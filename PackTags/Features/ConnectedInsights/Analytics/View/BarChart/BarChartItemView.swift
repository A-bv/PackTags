import SwiftUI

struct BarChartItemView: View {
    private enum Constants {
        static let barsOpacity: CGFloat = 0.06
        static let barMaxHeight: CGFloat = 50
        static let barChartTopPadding: CGFloat = 10
    }

    @Binding var selectedPostId: Int
    @Binding var selectedPostRate: CGFloat
    var colors: [Color]
    var post: BarChartPostModel
    
    private var fillGradient: LinearGradient {
        LinearGradient(
            gradient: .init(colors: selectedPostId == post.id ? colors : [Color(UIColor.label).opacity(Constants.barsOpacity)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func handleTapGesture() {
        withAnimation(.easeOut) {
            selectedPostId = post.id
            selectedPostRate = post.rate
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }

    var body: some View {
        VStack {
            VStack {
                Color(.clear)
                RoundedShape()
                    .fill(fillGradient)
                    .frame(height: post.barHeight)
                    .onTapGesture {
                        handleTapGesture()
                    }
            }
            .frame(height: Constants.barMaxHeight + Constants.barChartTopPadding)
            
            Text(post.post)
                .font(.caption2)
                .foregroundColor(Color(UIColor.label))
        }
    }
}
