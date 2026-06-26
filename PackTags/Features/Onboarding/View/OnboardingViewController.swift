import UIKit

final class OnboardingViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColor(white: 0.667, alpha: 1)
        pageControl.currentPageIndicatorTintColor = .systemPurple
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    private let getStartedBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Started".localized(), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - State

    private var scrollWidth: CGFloat = 0
    private var scrollHeight: CGFloat = 0

    private let titles = [
        Strings.onBoardingPageTitle1,
        Strings.onBoardingPageTitle2,
        Strings.onBoardingPageTitle3
    ]

    private let captions = [
        Strings.onBoardingPageSubtitle1,
        Strings.onBoardingPageSubtitle2,
        Strings.onBoardingPageSubtitle3
    ]

    private let illustrations = [
        "intro1",
        "intro4",
        "intro5"
    ]

    // MARK: - Dependencies & callbacks

    private let appSettings: any AppSettingsProtocol
    var onDismiss: (() -> Void)?

    // MARK: - Constants

    private enum Strings {
        static let onBoardingPageTitle1 = "WELCOME TO PACKTAGS".localized()
        static let onBoardingPageTitle2 = "UNIQUE PACKS".localized()
        static let onBoardingPageTitle3 = "ANALYTICS".localized()
        static let onBoardingPageSubtitle1 = "The smart notebook for your hashtags".localized()
        static let onBoardingPageSubtitle2 = "Automatically removes duplicates or invalid hashtags".localized()
        static let onBoardingPageSubtitle3 = "Tracks your results for the best strategy".localized()
    }

    private enum Constants {
        static let subtitleNumberOfLines = 3
        static let spacing10 = CGFloat(10)
        static let spacing30 = CGFloat(30)
        static let titleHeight = CGFloat(30)
        static let labelsXPadding = CGFloat(32)
        static let imageViewCenterPositionYAdjustment = -CGFloat(50)
        static let subtitleHeight = CGFloat(50)
        static let scrollWidthPadding = CGFloat(64)
        @MainActor static let screenWidth = UIScreen.main.bounds.width
        static let disableVerticalScrollOrBounceValue = CGFloat(1)

        static let smallScreenWidthLimit = CGFloat(320)
        @MainActor static let adaptiveImageViewLength = screenWidth <= smallScreenWidthLimit ? 200 : 300
        @MainActor static let fontSize1: CGFloat = screenWidth <= smallScreenWidthLimit ? 15.0 : 20.0
        @MainActor static let fontSize2: CGFloat = fontSize1 - 2
        // Dynamic Type ceilings (~1.4x of the base sizes, in line with the rest
        // of the app). The slide frames grow to fit, so larger text never clips.
        static let titleMaxFontSize: CGFloat = 28
        static let subtitleMaxFontSize: CGFloat = 24
    }

    // MARK: - Init

    init(appSettings: any AppSettingsProtocol) {
        self.appSettings = appSettings
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .colorOnBoardBg

        setupViewHierarchy()
        setupConstraints()
        view.layoutIfNeeded() // forces viewDidLayoutSubviews so the slide frames have a size

        setupGetStartedButton()
        setupScrollView()
        setupSlides()
        initializePageControl()
    }

    override func viewDidLayoutSubviews() {
        scrollWidth = scrollView.frame.size.width
        scrollHeight = scrollView.frame.size.height
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            onDismiss?()
        }
    }

    // MARK: - Setup

    private func setupViewHierarchy() {
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(getStartedBtn)
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),

            pageControl.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 20),
            pageControl.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 32),
            pageControl.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -32),

            getStartedBtn.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 20),
            getStartedBtn.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 32),
            getStartedBtn.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -32),
            safeArea.bottomAnchor.constraint(equalTo: getStartedBtn.bottomAnchor, constant: 35),
        ])
    }

    private func setupSlides() {
        for index in 0..<titles.count {
            addSlideToScrollView(makeSlide(index: index))
        }
    }

    private func setupGetStartedButton() {
        getStartedBtn.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
        getStartedBtn.isHidden = true
    }

    private func setupPageControlTarget() {
        pageControl.addTarget(self, action: #selector(pageChanged(_:)), for: .valueChanged)
    }

    private func initializePageControl() {
        pageControl.numberOfPages = titles.count
        pageControl.currentPage = 0
        setupPageControlTarget()
    }

    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }

    /// Height the label needs for its (possibly Dynamic-Type-scaled) text, never
    /// below the design's baseline height so default appearance is unchanged.
    private func heightToFit(_ label: UILabel, width: CGFloat, minimum: CGFloat) -> CGFloat {
        let fitted = label.sizeThatFits(
            CGSize(width: width, height: .greatestFiniteMagnitude)).height
        return max(minimum, ceil(fitted))
    }

    private func makeSlide(index: Int) -> UIView {
        let imageViewFrame = CGRect(
            x: 0,
            y: 0,
            width: Constants.adaptiveImageViewLength,
            height: Constants.adaptiveImageViewLength)
        let imageViewCenter = CGPoint(
            x: scrollWidth / 2,
            y: scrollHeight / 2 + Constants.imageViewCenterPositionYAdjustment)

        let imageView = UIImageView(image: UIImage(named: illustrations[index]))
        imageView.frame = imageViewFrame
        imageView.contentMode = .scaleAspectFit
        imageView.center = imageViewCenter

        let labelWidth = scrollWidth - Constants.scrollWidthPadding

        let title = UILabel()
        title.textAlignment = .center
        title.numberOfLines = 0
        title.font = UIFontMetrics(forTextStyle: .title2).scaledFont(
            for: UIFont.boldSystemFont(ofSize: Constants.fontSize1),
            maximumPointSize: Constants.titleMaxFontSize)
        title.adjustsFontForContentSizeCategory = true
        title.text = titles[index]
        title.frame = CGRect(
            x: Constants.labelsXPadding,
            y: imageView.frame.maxY + Constants.spacing30,
            width: labelWidth,
            height: heightToFit(title, width: labelWidth, minimum: Constants.titleHeight))

        let subtitle = UILabel()
        subtitle.textAlignment = .center
        subtitle.numberOfLines = Constants.subtitleNumberOfLines
        subtitle.font = UIFontMetrics(forTextStyle: .body).scaledFont(
            for: UIFont.systemFont(ofSize: Constants.fontSize2),
            maximumPointSize: Constants.subtitleMaxFontSize)
        subtitle.adjustsFontForContentSizeCategory = true
        subtitle.text = captions[index]
        subtitle.frame = CGRect(
            x: Constants.labelsXPadding,
            y: title.frame.maxY + Constants.spacing10,
            width: labelWidth,
            height: heightToFit(subtitle, width: labelWidth, minimum: Constants.subtitleHeight))

        let slideFrame = CGRect(
            x: scrollWidth * CGFloat(index),
            y: 0,
            width: scrollWidth,
            height: scrollHeight)
        let slide = UIView(frame: slideFrame)
        slide.addSubview(imageView)
        slide.addSubview(subtitle)
        slide.addSubview(title)

        // VoiceOver reads each page as one element (the illustration is decorative);
        // the page control announces "page x of y".
        slide.isAccessibilityElement = true
        slide.accessibilityLabel = "\(titles[index]). \(captions[index])"

        return slide
    }

    private func addSlideToScrollView(_ slide: UIView) {
        let widthToFitAllSlides = scrollWidth * CGFloat(titles.count)
        scrollView.contentSize = CGSize(
            width: widthToFitAllSlides,
            height: scrollHeight)
        scrollView.contentSize.height = Constants.disableVerticalScrollOrBounceValue
        scrollView.addSubview(slide)
    }
}

// MARK: - Scrolling & actions

extension OnboardingViewController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setIndicatorForCurrentPage()
    }

    private func setIndicatorForCurrentPage() {
        let page = scrollView.contentOffset.x / scrollWidth
        pageControl.currentPage = Int(page)
        getStartedBtn.isHidden = Int(page) != titles.count - 1
    }

    @objc private func pageChanged(_ sender: Any) {
        let currentPage = CGFloat(pageControl.currentPage)
        let pageControlFrame = CGRect(
            x: scrollWidth * currentPage,
            y: 0,
            width: scrollWidth,
            height: scrollHeight)
        scrollView.scrollRectToVisible(pageControlFrame, animated: true)
    }

    @objc private func didTap(_ sender: UIButton) {
        appSettings.hasSeenOnboarding = true
        dismiss(animated: true)
    }
}
