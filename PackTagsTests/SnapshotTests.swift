import XCTest
import SwiftUI
import SnapshotTesting
@testable import PackTags

/// Reference-image tests: render key views in light + dark so appearance regressions
/// — notably the neumorphic dark-mode behaviour — are caught automatically rather than
/// by eyeballing the simulator.
///
/// Views are rendered through a real key window with a run-loop tick before capture:
/// SwiftUI text rasterises via `drawHierarchy(afterScreenUpdates:)`, which needs a
/// screen-update cycle that a synchronous test would otherwise skip (leaving glyphs blank).
@MainActor
final class ViewSnapshotTests: XCTestCase {

    private func assertLightAndDark<V: View>(
        _ view: V,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        for style: UIUserInterfaceStyle in [.light, .dark] {
            assertSnapshot(
                of: render(view, style: style),
                as: .image(precision: 0.99, perceptualPrecision: 0.98),
                named: style == .dark ? "dark" : "light",
                file: file, testName: testName, line: line)
        }
    }

    private func render<V: View>(_ view: V, style: UIUserInterfaceStyle) -> UIImage {
        let host = UIHostingController(rootView: view)
        host.overrideUserInterfaceStyle = style
        host.view.backgroundColor = .systemBackground
        let size = host.sizeThatFits(in: CGSize(width: 600, height: 2000))
        host.view.frame = CGRect(origin: .zero, size: size)

        let window = UIWindow(frame: host.view.frame)
        window.overrideUserInterfaceStyle = style
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.layoutIfNeeded()
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))

        let renderer = UIGraphicsImageRenderer(bounds: host.view.bounds)
        return renderer.image { _ in
            host.view.drawHierarchy(in: host.view.bounds, afterScreenUpdates: true)
        }
    }

    func testSmartGHeader() {
        assertLightAndDark(SmartGHeaderView())
    }

    /// Neumorphic gauge — the dark-mode behaviour that regressed and was hand-fixed; now
    /// pinned in both appearances.
    func testMonoCircle() {
        assertLightAndDark(MonoCircleView(monoCircleValue: 12.1, isRate: false))
    }

    /// The UIKit neumorphic cell (CALayer shadows) — covers the exact regression where the
    /// thumbnail shadow vanished on a dark→light switch.
    func testThemeCell() {
        assertCellLightAndDark(width: 390, height: 160) {
            let cell = ThemeCell(style: .default, reuseIdentifier: nil)
            cell.nameLabel.text = "Travel"
            return cell
        }
    }

    private func assertCellLightAndDark(
        width: CGFloat,
        height: CGFloat,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        _ make: () -> UITableViewCell
    ) {
        for style: UIUserInterfaceStyle in [.light, .dark] {
            assertSnapshot(
                of: render(make(), size: CGSize(width: width, height: height), style: style),
                as: .image(precision: 0.99, perceptualPrecision: 0.98),
                named: style == .dark ? "dark" : "light",
                file: file, testName: testName, line: line)
        }
    }

    /// Renders a UIKit view in a real key window under the given appearance — so the
    /// neumorphic shadow's `registerForTraitChanges` repaint actually fires before capture.
    private func render(_ view: UIView, size: CGSize, style: UIUserInterfaceStyle) -> UIImage {
        view.frame = CGRect(origin: .zero, size: size)
        view.overrideUserInterfaceStyle = style
        let window = UIWindow(frame: view.frame)
        window.overrideUserInterfaceStyle = style
        window.addSubview(view)
        window.makeKeyAndVisible()
        view.layoutIfNeeded()
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))

        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
