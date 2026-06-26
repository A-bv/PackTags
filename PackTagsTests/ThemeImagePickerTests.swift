import Testing
import UIKit
@testable import PackTags

@MainActor
@Suite struct ThemeImagePickerTests {

    /// The whole point of the loading overlay is that it's already on screen
    /// while the (slow, first-launch) picker presentation runs, and gone once
    /// the picker is up. The real PHPicker timing can't be unit tested, so we
    /// drive the presentation through the injectable `presentPicker` seam.
    @Test func showsLoadingBeforePresenting_andHidesOncePresented() {
        let picker = ThemeImagePicker()
        let host = UIViewController()
        host.loadViewIfNeeded()

        var loadingWhilePresenting: Bool?
        var overlayOnScreenWhilePresenting: Bool?
        picker.presentPicker = { _, _, onPresented in
            loadingWhilePresenting = picker.isLoading
            overlayOnScreenWhilePresenting = !host.view.subviews.isEmpty
            onPresented() // simulate the picker finishing its presentation
        }

        #expect(picker.isLoading == false)        // nothing shown yet
        #expect(host.view.subviews.isEmpty)

        picker.present(from: host) { _ in }

        #expect(loadingWhilePresenting == true)       // overlay up during presentation
        #expect(overlayOnScreenWhilePresenting == true)
        #expect(picker.isLoading == false)            // and removed once presented
        #expect(host.view.subviews.isEmpty)
    }
}
