import SwiftUI

struct SmartGSavedTagsCell: View {
    let title: String
    let date: String
    var body: some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
                Text(date)
            }
        }
    }
}
