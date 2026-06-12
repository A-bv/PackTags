import SwiftUI

private enum Constants {
    static let collectionInterMediasPadding: CGFloat = 20
    static let collectionLeadingPadding: CGFloat = 20
    static let collectionBottomPadding: CGFloat = 20
}

struct CollectionView: View {
    @ObservedObject var viewModel: SmartGViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.collectionInterMediasPadding) {
                makeStoryCards()
            }
        }
        .padding(.leading, Constants.collectionLeadingPadding)
        .padding(.bottom, Constants.collectionBottomPadding)
    }
}

extension SmartGView {
    var collection: some View {
        CollectionView(viewModel: self.smartGViewModel)
    }
}

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionView(viewModel: SmartGViewModel(gateway: UnavailableConnectedInsightsGateway()))
    }
}
