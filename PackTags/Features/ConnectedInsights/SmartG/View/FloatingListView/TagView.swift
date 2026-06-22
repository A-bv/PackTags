import SwiftUI

struct TagView: View {
    let color: Color
    let index: Int
    let item: String
    @Binding var childSizes: [CGSize]
    let x: CGFloat
    let y: CGFloat
    let tagPadding: CGFloat
    let tagCornerRadius: CGFloat
    
    var body: some View {
        Button(action: {
            UIPasteboard.general.string = item
        }) {
            Text("\(item)")
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                childSizes[index] = geometry.size
                            }
                    })
                .foregroundColor(.white)
                .font(.headline)
                .padding(tagPadding)
                .background(color)
                .cornerRadius(tagCornerRadius)
        }
        .offset(x: x, y: y)
    }
}

#Preview {
    TagView(
        color: .brandAccent,
        index: 0,
        item: "#example",
        childSizes: .constant([.zero]),
        x: 0,
        y: 0,
        tagPadding: 10,
        tagCornerRadius: 10)
}
