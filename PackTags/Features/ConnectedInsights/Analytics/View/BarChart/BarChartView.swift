import SwiftUI

struct BarChartView: View {
    private enum Constants {
        static let barChartHorizontalSpacing: CGFloat = 10
    }
    
    @Binding var selectedBarChartPostId: Int
    @Binding var selectedBarChartPostRateValue: CGFloat
    @Binding var barchartPostList: [BarChartPost]
    var colors: [Color]

    var body: some View {
        HStack(spacing: Constants.barChartHorizontalSpacing) {
            ForEach(barchartPostList) { post in
                BarChartItemView(
                    selectedPostId: $selectedBarChartPostId,
                    selectedPostRate: $selectedBarChartPostRateValue,
                    colors: colors,
                    post: post)
            }
        }
    }
}

#Preview {
    let data = [
        BarChartPost(id: 1, post: "Post1", rate: CGFloat(0), barHeight: CGFloat(32.5)),
        BarChartPost(id: 2, post: "Post2", rate: CGFloat(0), barHeight: CGFloat(43.75)),
        BarChartPost(id: 3, post: "Post3", rate: CGFloat(0), barHeight: CGFloat(22.5)),
        BarChartPost(id: 1, post: "Post1", rate: CGFloat(0), barHeight: CGFloat(32.5)),
        BarChartPost(id: 2, post: "Post2", rate: CGFloat(0), barHeight: CGFloat(43.75)),
        BarChartPost(id: 3, post: "Post3", rate: CGFloat(0), barHeight: CGFloat(22.5))
    ]
    return BarChartView(
        selectedBarChartPostId: .constant(2),
        selectedBarChartPostRateValue: .constant(0.0),
        barchartPostList: .constant(data),
        colors: [.blue, .green])
    .padding()
}
