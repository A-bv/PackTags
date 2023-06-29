//
//  AnalyticsNew.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09.01.21.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//
//(U) = data loading operations
// D = dismiss view operations

import SwiftUI

struct AnalyticsNew_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsNew()
    }
}

struct AnalyticsNew : View {
    
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
        static let ok = "Ok"
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
    
    //
    @ObservedObject var swiftUIData = AnalyticsSUIViewModel()
    
    //
    @State private var showingAlert = false
    
    //Dismiss the view
    @Environment(\.presentationMode) var presentationMode
    
    //Network Status
    @ObservedObject var monitor = NetworkMonitor()
    
    //
    @State var selected = 0

    var colors = [Color("Color1"),Color("Color")]
    var columns = Array(
        repeating:
            GridItem(
                .flexible(),
                spacing: Constants.overviewSectionColumnsSpacing),
        count: Constants.overviewSectionColumnsCount)
    
    //
    @State var titles = [
        Strings.engagement,
        Strings.reach,
        Strings.impressions]
    @State var subtitles = [
        " ",
        " ",
        " "]
    @State var infoTitles = [
        Strings.eR,
        Strings.eRR,
        Strings.eRI]
    @State var infoMessages = [
        Strings.engagementDefinition,
        "\n\(Strings.reachDefinition)",
        "\n\(Strings.impressionsDefinition)"]
    
    @State var loading = true
    
    //Layout
    @State var graphSectionHorizontalPadding = UIScreen.main.bounds.size.width
    < Constants.smallScreenWidthLimit
    ? 0
    : Constants.graphSectionHorizontalPadding
    
    //Toggle button
    @State private var isToggled = false
    
    init() {
        //Navigation bar customization
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.clear
        ]
    }
    
    var body: some View {
        ZStack {
            Color.bgFillColor.ignoresSafeArea()
            
            VStack {
                header
                
                if !monitor.isConnected {
                    OfflineView()
                } else if swiftUIData.jsonOfficial == nil {
                    LoadingView(loading: $loading)
                } else {
                    if swiftUIData.processedJson?.isPrivateProfile == true {
                        Color.bgFillColor
                            .edgesIgnoringSafeArea(.all)
                        Text(Strings.privateProfile)
                    } else if swiftUIData.processedJson?.rates == Optional([]) {
                        // Screen when data is invalid
                        Color.bgFillColor
                            .edgesIgnoringSafeArea(.all)
                        if swiftUIData.processedJson?.usr != nil {
                            Text(Strings.noMedia)
                                .multilineTextAlignment(.center)
                        } else {
                            Text(Strings.dataUnavailable)
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        // Screen when data is available
                        scrollView
                    }
                }
            }
        }
    }
}

//MARK: - Functions
extension AnalyticsNew {  
    func updateLabels () {
        let rawMetricsLabels = [
            Strings.engagement,
            Strings.reach,
            Strings.impressions
        ]
        
        titles = rawInsights == true ? rawMetricsLabels : [
            Strings.engagement,
            Strings.engagement,
            Strings.engagement]
        
        subtitles = rawInsights == true ? [" "," "," "] : [
            Strings.ratioToFollower,
            Strings.ratioByReach,
            Strings.ratioByImpressions
        ]
        
        infoTitles = rawInsights == true ? rawMetricsLabels : [
            Strings.eR,
            Strings.eRR,
            Strings.eRI
        ]
            
        infoMessages = rawInsights == true ?
        [
            "\n\(Strings.engagementDefinition)",
            "\n\(Strings.reachDefinition)",
            "\n\(Strings.impressionsDefinition)"
        ] : [
            "\n\(Strings.eRDefiniton)",
            "\n\(Strings.eRRDefiniton)",
            "\n\(Strings.eRIDefinition)"
        ]
    }
}

//MARK: - Elements
// Header
extension AnalyticsNew {
    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: Constants.headerVerticalSpacing) {
                Text(Strings.analyticsTitle)
                    .font(.largeTitle)
                    .foregroundColor(Color(UIColor.label))
                    .fontWeight(.bold)
                    
                Text(swiftUIData.processedJson?.usr ?? " ")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.label))
            }
            
            Spacer()
            
            Button(action: {
                rawInsights = true
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.down.circle")
                    .font(Font.system(.title))
                    .foregroundColor(Color(UIColor.label))
            }
        }
        .padding()
    }
}

// Scrollview
extension AnalyticsNew {
    var scrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            //MARK: - Graph part
            VStack(
                spacing: Constants.scrollViewVerticalSpacing
            ) {
                graphSectionHeader
                if let postCount = swiftUIData.processedJson?.postsCount,
                   let average = swiftUIData.processedJson?.avg2
                {
                    if postCount == 1 {
                        MonoCircleView(
                            monoCircleValue: Double(average),
                            rawInsights: rawInsights)
                        Spacer()
                    } else {
                        CirclesView(
                            circles: $swiftUIData.circlesData,
                            rawInsights: rawInsights,
                            columns: columns)
                        BarchartView(
                            selected: $selected,
                            rate: $swiftUIData.circlesData[1].value,
                            chartData: $swiftUIData.barChartData,
                            colors: colors)
                        BarchartArrowsView(postsCount: postCount)
                    }
                }
            }
            .padding()
            .padding(
                EdgeInsets(
                    top: 0,
                    leading: CGFloat(graphSectionHorizontalPadding),
                    bottom: 0,
                    trailing: CGFloat(graphSectionHorizontalPadding)))
               
            //MARK: - Overview part
            overviewSection
        }
    }
}

// Overview
extension AnalyticsNew {
    var overviewSection: some View{
        LazyVGrid(columns: columns) {
            ForEach(swiftUIData.overviewSectionData) { overviewCell in
                //ZStack{
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
extension AnalyticsNew {
    var graphSectionHeader: some View {
        HStack{
            VStack(alignment: .leading, spacing: Constants.graphSectionHeaderVerticalSpacing) {
                HStack {
                    Text(titles[mode])
                        .font(.title)
                        .foregroundColor(Color(UIColor.label))
                    //Info Button
                    Button(
                        action: {
                            showingAlert = true
                            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                        }
                    ) {
                        Image(systemName: "info.circle")
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text(infoTitles[mode]),
                            message:Text(infoMessages[mode]),
                            dismissButton: .default(Text(Strings.ok)))
                    }
                }
                Text(subtitles[mode])
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.label))
            }
            Spacer()
            HStack {
                // Insights - Rates button toggle
                Toggle(isOn: $isToggled) {
                    Image(
                        systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up")
                        .foregroundColor(Color("Color4"))
                }
                .toggleStyle(DarkToggleStyle())
                .padding(.trailing, Constants.graphSectionHeaderTraillingPadding)
                .onChange(of: isToggled)
                { _ in
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                        
                    rawInsights = !rawInsights
                    updateLabels()
                    
                    swiftUIData.getJsonFromDir()
                }

                //Switch mode Button
                Button(action: {
                    let impactMed = UIImpactFeedbackGenerator(style: .soft)
                    impactMed.impactOccurred()
                        
                    mode += 1
                    if mode == Constants.maxNumberOfModes {
                        mode = 0
                    }
                    
                    swiftUIData.getJsonFromDir()

                }) {
                    Image(systemName: "scale.3d")
                        .foregroundColor(Color("Color4"))
                }
                .buttonStyle(ColorfulButtonStyle())
                .padding(.trailing,0)
            }
        }
    }
}
