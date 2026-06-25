import SwiftUI

/// Process-wide cache of decoded remote images, keyed by URL. `NSCache` is documented
/// thread-safe, so the shared instance is safe to reach from any isolation.
nonisolated(unsafe) private let imageMemoryCache = NSCache<NSURL, UIImage>()

/// A drop-in async image that decodes each URL once and serves it from a shared cache
/// thereafter — so a horizontally scrolling carousel doesn't re-download and re-decode
/// the same remote image every time a card is reused. Shows `placeholder` while loading
/// or on failure.
struct CachedAsyncImage<Placeholder: View>: View {
    let url: URL
    @ViewBuilder var placeholder: () -> Placeholder

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image).resizable()
            } else {
                placeholder()
            }
        }
        .task(id: url) { await load() }
    }

    private func load() async {
        if let cached = imageMemoryCache.object(forKey: url as NSURL) {
            image = cached
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let decoded = UIImage(data: data) else { return }
            imageMemoryCache.setObject(decoded, forKey: url as NSURL)
            image = decoded
        } catch {
            AppLogger.ui.error("Image load failed: \(error.localizedDescription, privacy: .private)")
        }
    }
}
