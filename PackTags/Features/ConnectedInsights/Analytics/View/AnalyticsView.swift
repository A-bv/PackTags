import SwiftUI
import InstagramGraph

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView(gateway: UnavailableConnectedInsightsGateway())
    }
}

struct AnalyticsView : View {
    
    private enum Strings {
        static let average = "Average".localized()
        static let noMedia = "No media have been posted yet\nas a Business/Creator account".localized()
        static let dataUnavailable = "Data unavailable\n\nOr\n\nLikely no new posts\nas a Business/Creator account".localized()
        static let engagement = "Engagement".localized()
        static let reach = "Reach".localized()
        static let impressions = "Impressions".localized()
        static let eR = "Engagement Rate (ER)".localized()
        static let eRR = "Engagement Rate by Reach (ERR)".localized()
        static let eRI = "Engagement Rate by Impressions (ER Impressions)".localized()
        static let analyticsTitle = "Analytics".localized()
        static let privateProfile = "Profile is private".localized()
        static let ratioToFollower = "Per Follower".localized()
        static let ratioByReach = "By Reach".localized()
        static let ratioByImpressions = "By Impressions".localized()
        static let engagementDefinition = "Engagement = Likes + Comments\n\nEngagement is a metric used to determine the number of interactions your content receives.".localized()
        static let reachDefinition = "Reach is the total number of people (single accounts) who saw your content.".localized()
        static let impressionsDefinition = "Impressions represents how many times your content appeared on a screen, no matter if it was clicked or not.".localized()
        static let eRDefiniton = "ER = Likes and Comments / Followers * 100\n\nEngagement Rate is a metric used to determine the number of interactions your content receives, relatively to your followers.".localized()
        static let eRRDefiniton = "ERR = Likes and Comments / Reach * 100\n\nEngagement Rate by Reach is a metric used to determine the number of interactions your content receives, relatively to each single account who saw your content.".localized()
        static let eRIDefinition = "ER impressions = Likes and Comments / Impressions *100\n\nIf your ER impressions is lower than your ERR, then it is a good sign, as your content is viewed multiple times by a single account.".localized()
        static let ok = "Ok".localized()
        static let closeAnalytics = "Close analytics".localized()
        static let toggleRawAndRates = "Switch between values and rates".localized()
        static let nextMetric = "Next metric".localized()
    }
    
    private enum Constants {
        static let overviewSectionColumnsCount: Int = 2
        static let overviewSectionColumnsSpacing: CGFloat = 20
        static let headerVerticalSpacing: CGFloat = 5
        static let scrollViewVerticalSpacing: CGFloat = 25
        static let smallScreenWidthLimit: CGFloat = 375 // iPhone 13 mini / SE
        static let graphSectionHorizontalPadding: CGFloat = 17.5
        static let overviewCellHeaderToValuePadding: CGFloat = 20
        static let overviewCellValueFontSize: CGFloat = 22
        static let overviewCellCornerRadius: CGFloat = 15
        static let overviewCellToEdgeHorizontalPadding: CGFloat = 20
        static let maxNumberOfModes: Int = 3  // 1 followers, 2 reach, 3 impressions
        static let graphSectionHeaderVerticalSpacing: CGFloat = 5
        static let graphSectionHeaderTraillingPadding: CGFloat = 10
    }
    
    @State var swiftUIData: AnalyticsViewModel
    @State private var showingAlert = false
    @Environment(\.dismiss) private var dismiss
    @State private var monitor: NetworkMonitor
    @State var selectedBarChartPostId = 0

    var colors = [Color("Color1"),Color("Color")]

    init(gateway: any ConnectedInsightsGatewayProtocol, monitor: NetworkMonitor = NetworkMonitor()) {
        _swiftUIData = State(initialValue: AnalyticsViewModel(gateway: gateway))
        _monitor = State(initialValue: monitor)
    }

    var columns = Array(
        repeating:
            GridItem(
                .flexible(),
                spacing: Constants.overviewSectionColumnsSpacing),
        count: Constants.overviewSectionColumnsCount)

    //Toggle button
    @State private var isToggled = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.bgFillColor
                    .ignoresSafeArea()

                VStack {
                    header

                    Spacer()

                    if !monitor.isConnected {
                        OfflineView()
                    } else if swiftUIData.jsonOfficial == nil {
                        LoadingView(loading: .constant(true))
                    } else {
                        if swiftUIData.processedJson?.isPrivateProfile == true {
                            Text(Strings.privateProfile)
                        } else if swiftUIData.processedJson?.rates == Optional([]) {
                            // Screen when data is invalid
                            if swiftUIData.processedJson?.username != nil {
                                Text(Strings.noMedia)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text(Strings.dataUnavailable)
                                    .multilineTextAlignment(.center)
                            }
                        } else {
                            // Screen when data is available
                            scrollView(
                                graphPadding: graphPadding(forWidth: geometry.size.width),
                                availableWidth: geometry.size.width)
                        }
                    }

                    Spacer()
                }
            }
        }
        .task {
            await swiftUIData.load()
        }
    }

    private func graphPadding(forWidth width: CGFloat) -> CGFloat {
        width < Constants.smallScreenWidthLimit ? 0 : Constants.graphSectionHorizontalPadding
    }
}

//MARK: - Mode-dependent labels (computed from the view model, never stored)
extension AnalyticsView {
    private var titles: [String] {
        swiftUIData.rawInsights
            ? [Strings.engagement, Strings.reach, Strings.impressions]
            : [Strings.engagement, Strings.engagement, Strings.engagement]
    }

    private var subtitles: [String] {
        swiftUIData.rawInsights
            ? [" ", " ", " "]
            : [Strings.ratioToFollower, Strings.ratioByReach, Strings.ratioByImpressions]
    }

    private var infoTitles: [String] {
        swiftUIData.rawInsights
            ? [Strings.engagement, Strings.reach, Strings.impressions]
            : [Strings.eR, Strings.eRR, Strings.eRI]
    }

    private var infoMessages: [String] {
        swiftUIData.rawInsights
            ? ["\n\(Strings.engagementDefinition)", "\n\(Strings.reachDefinition)", "\n\(Strings.impressionsDefinition)"]
            : ["\n\(Strings.eRDefiniton)", "\n\(Strings.eRRDefiniton)", "\n\(Strings.eRIDefinition)"]
    }
}

//MARK: - Functions
extension AnalyticsView {
    private func changeInsightType() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()

        swiftUIData.rawInsights.toggle()
        swiftUIData.refreshFromCurrentProfile()
    }

    private func switchInsightToRate() {
        let impactMed = UIImpactFeedbackGenerator(style: .soft)
        impactMed.impactOccurred()

        swiftUIData.mode += 1
        if swiftUIData.mode == Constants.maxNumberOfModes {
            swiftUIData.mode = 0
        }

        swiftUIData.refreshFromCurrentProfile()
    }
}

//MARK: - Buttons
extension AnalyticsView {
    var backButton: some View {
        Button(action: {
            swiftUIData.rawInsights = true
            dismiss()
        }) {
            Image(systemName: "chevron.down.circle")
                .font(Font.system(.title))
                .foregroundColor(Color(UIColor.label))
        }
        .accessibilityLabel(Text(Strings.closeAnalytics))
    }

    var infoButton: some View {
        Button(action: {
            showingAlert = true
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }) {
            Image(systemName: "info.circle")
        }
        .accessibilityLabel(Text(infoTitles[swiftUIData.mode]))
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(infoTitles[swiftUIData.mode]),
                message:Text(infoMessages[swiftUIData.mode]),
                dismissButton: .default(Text(Strings.ok)))
        }
    }

    var insightsRatesToggleButton: some View {
        Toggle(isOn: $isToggled) {
            Image(systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up")
                .foregroundColor(Color("Color4"))
        }
        .accessibilityLabel(Text(Strings.toggleRawAndRates))
        .toggleStyle(DarkToggleStyle())
        .padding(.trailing, Constants.graphSectionHeaderTraillingPadding)
        .onChange(of: isToggled) { _ in changeInsightType() }
    }

    var switchModeButton: some View {
        Button(action: { switchInsightToRate() }) {
            Image(systemName: "scale.3d")
                .foregroundColor(Color("Color4"))
        }
        .accessibilityLabel(Text(Strings.nextMetric))
        .buttonStyle(ColorfulButtonStyle())
    }
}

//MARK: - Elements
// Header
extension AnalyticsView {
    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: Constants.headerVerticalSpacing) {
                Text(Strings.analyticsTitle)
                    .font(.largeTitle)
                    .foregroundColor(Color(UIColor.label))
                    .fontWeight(.bold)
                
                Text(swiftUIData.processedJson?.username ?? " ")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.label))
            }
            Spacer()
            backButton
        }
        .padding()
    }
}

// Scrollview
extension AnalyticsView {
    func scrollView(graphPadding: CGFloat, availableWidth: CGFloat) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            //MARK: - Graph part
            VStack(
                spacing: Constants.scrollViewVerticalSpacing
            ) {
                HStack{
                    graphSectionHeader
                    Spacer()
                    graphSectionHeaderButtons
                }

                if let postCount = swiftUIData.processedJson?.postsCount,
                   let average = swiftUIData.processedJson?.averageRate
                {
                    if postCount == 1 {
                        MonoCircleView(
                            monoCircleValue: Double(average),
                            isRate: !swiftUIData.rawInsights)
                        Spacer()
                    } else {
                        CirclesView(
                            circles: $swiftUIData.circlesData,
                            isRate: !swiftUIData.rawInsights,
                            columns: columns,
                            availableWidth: availableWidth)
                        BarchartView(
                            selectedBarChartPostId: $selectedBarChartPostId,
                            selectedBarChartPostRateValue: $swiftUIData.circlesData[1].value,
                            barchartPostList: $swiftUIData.barChartData,
                            colors: colors)
                        BarchartArrowsView(postsCount: postCount)
                    }
                }
            }
            .padding()
            .padding(
                EdgeInsets(
                    top: 0,
                    leading: graphPadding,
                    bottom: 0,
                    trailing: graphPadding))
               
            //MARK: - Overview part
            overviewSection
        }
    }
}

// Overview
extension AnalyticsView {
    var overviewSection: some View{
        LazyVGrid(columns: columns) {
            ForEach(swiftUIData.overviewSectionData) { overviewCell in
                VStack(spacing: Constants.overviewCellHeaderToValuePadding){
                    HStack{
                        Text(swiftUIData.processedJson?.postsCount == 1 ? "" : Strings.average)
                            .font(.body)
                            .foregroundColor(Color(UIColor.label))
                        Spacer(minLength: 0)
                        overviewCell.image
                            .font(Font.system(.title2))
                    }
                    Text(overviewCell.value)
                        .font(.system(size: Constants.overviewCellValueFontSize))
                        .foregroundColor(Color(UIColor.label))
                        .fontWeight(.bold)
                    Text(overviewCell.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(UIColor.label))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Constants.overviewCellCornerRadius)
                        .outerNeumorphism(Color.statsFillColor))
            }
        }
        .padding(
            EdgeInsets(
                top: 0,
                leading: Constants.overviewCellToEdgeHorizontalPadding,
                bottom: 0,
                trailing: Constants.overviewCellToEdgeHorizontalPadding))
    }
}

// GraphsHeader
extension AnalyticsView {
    var graphSectionHeader: some View {
        VStack(alignment: .leading, spacing: Constants.graphSectionHeaderVerticalSpacing) {
            HStack {
                Text(titles[swiftUIData.mode])
                    .font(.title)
                    .foregroundColor(Color(UIColor.label))
                infoButton
            }
            Text(subtitles[swiftUIData.mode])
                .font(.subheadline)
                .foregroundColor(Color(UIColor.label))
        }
    }

    var graphSectionHeaderButtons: some View {
        HStack {
            insightsRatesToggleButton
            switchModeButton
        }
    }
}
