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
        static let previousPosts = "Previous posts".localized()
        static let previousPost = "Previous post".localized()
        static let latest = "Latest post".localized()
        static let noMedia = "No media have been posted yet\nas a Business/Creator account".localized()
        static let dataUnavailable = "Data unavailable\n\nOr\n\nLikely no new posts\nas a Business/Creator account".localized()
        static let engagement = "Engagement".localized()
        static let reach = "Reach".localized()
        static let impressions = "Impressions".localized()
        static let eR = "Engagement Rate (ER)".localized()
        static let eRR = "Engagement Rate by Reach (ERR)".localized()
        static let eRI = "Engagement Rate by Impressions (ER Impressions)".localized()
        static let analyticsTitle = "Analytics".localized()
        static let notConnected = "Not connected".localized()
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
    }
    
    //
    @ObservedObject var swiftUIData = AnalyticsVCModels()
    
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
        repeating: GridItem(
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
    
    var body: some View{
        ZStack {
            Color.bgFillColor.ignoresSafeArea()
            
            VStack(){
                //MARK: - Screen Header
                header
                //MARK: - Screen selection
                
                
                if monitor.isConnected == false {
                    offlineView
                } else if swiftUIData.jsonOfficial == nil {
                    loadingView
                } else {
                    //Screen when profile is private (unofficial Json)
                    if swiftUIData.processedJson?.isPv == true {
                        ZStack {
                            Color.bgFillColor
                                .edgesIgnoringSafeArea(.all)
                            Text(Strings.privateProfile)
                        }
                    } else if swiftUIData.processedJson?.rates == Optional([]) {
                        //Screen when data is invalid
                        ZStack {
                            Color.bgFillColor
                                .edgesIgnoringSafeArea(.all)
                            if swiftUIData.processedJson?.usr != nil {
                                Text(Strings.noMedia)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text(Strings.dataUnavailable)
                                    .multilineTextAlignment(.center)
                            }
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
    //AAA 2
    func updateCircle (v1:CGFloat,v2:CGFloat) -> Bool {
        swiftUIData.circles_Data[1].currentData = CGFloat(v1)
        swiftUIData.circles_Data[1].variation = v2
        return true
    }
    
    func updateLabels () -> Bool {
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
        return true
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
                AnalyticsVCModels.lastSelected = 0
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
                alignment: .leading,
                spacing: Constants.scrollViewVerticalSpacing
            ) {
                graphsHeader
                if swiftUIData.processedJson?.postsCount == 1 {
                    monoCirle
                }
                else {
                    circles
                    barchart
                    barchartArrows
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
                            //.font(.system(size: 20))
                            //.fontWeight(.bold)
                            .foregroundColor(Color(UIColor.label))
                        Spacer(minLength: 0)
                        overviewCell.image
                            .font(Font.system(.title2))
                    }
                    Text(overviewCell.currentData)
                        .font(.system(size: Constants.overviewCellValueFontSize))
                        .foregroundColor(Color(UIColor.label))
                        .fontWeight(.bold)
                    Text(overviewCell.title)
                        //.font(.system(size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(Color(UIColor.label))
                        .frame(maxWidth: .infinity, alignment: .center)
                        //Spacer(minLength: 0)
                        //Spacer()
                }
                .padding()
                //.background(Color(UIColor.label).opacity(0.06))
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

// Barchart
extension AnalyticsNew {
    var barchart: some View{
        HStack(spacing: 10){
            
            ForEach(swiftUIData.graph_Data ?? []){value in
                
                // Bars...
                VStack{
                    VStack{
                        Spacer(minLength: 0)
                        
                        RoundedShape()
                            .fill(
                                LinearGradient(
                                    gradient: .init(
                                        colors: selected == value.id
                                        ? colors
                                        : [Color(UIColor.label).opacity(0.06)]),
                                    startPoint: .top, endPoint: .bottom))
                        
                        // max height = 50
                            .frame(height: value.barHeight)
                        
                    }
                    .frame(height: 60)
                    //100) //50+10
                    .onTapGesture {
                        withAnimation(.easeOut){
                            selected = value.id
                            let _ = updateCircle(v1:value.r,v2:value.rVr)
                            AnalyticsVCModels.lastSelected = value.id
                            let impactMed = UIImpactFeedbackGenerator(style: .soft)
                            impactMed.impactOccurred()
                        }
                    }
                    
                    Text(value.post)
                        .font(.caption2)
                        .foregroundColor(Color(UIColor.label))
                }
            }
        }
    }
    
    var barchartArrows: some View{
        HStack {
            let num = swiftUIData.processedJson?.postsCount
            if num != 1 {
            Image(systemName: "arrow.turn.left.up")
                .font(.caption)
                .foregroundColor(Color(UIColor.label).opacity(0.6))
            Text(Strings.latest)
                .font(.caption)
                .foregroundColor(Color(UIColor.label).opacity(0.6))
            }
            Spacer()
            
            let text2 = num != 1 ? Strings.previousPosts : Strings.previousPost
            // "Last \(num ?? 0) Posts" : Strings.previousPosts
            Text(text2)
                .font(.caption)
                .foregroundColor(Color(UIColor.label).opacity(0.6))
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundColor(Color(UIColor.label).opacity(0.6))
        }
    }
}

// GraphsHeader
extension AnalyticsNew {
    var graphsHeader: some View {
        HStack{
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(titles[mode])
                        .font(.title)
                        .foregroundColor(Color(UIColor.label))
                    
                    //Info Button
                    Button(action: {
                        showingAlert = true
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    }) {
                        Image(systemName: "info.circle")
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text(infoTitles[mode]), message:Text(infoMessages[mode]), dismissButton: .default(Text("Ok")))
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
                .padding(.trailing, 10)
                .onChange(of: isToggled)
                { _ in
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                        
                    rawInsights = !rawInsights
                    let _ = updateLabels ()
                    
                    swiftUIData.getJsonFromDir()
                }

                //Switch mode Button
                Button(action: {
                    let impactMed = UIImpactFeedbackGenerator(style: .soft)
                    impactMed.impactOccurred()
                        
                    mode = mode + 1
                    if mode == 3 { //1followers, 2reach, 3impr
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

// Cirles
extension AnalyticsNew {
    var circles: some View{
        LazyVGrid(columns: columns,spacing: 30){

        ForEach(swiftUIData.circles_Data){circle in
            VStack(spacing: 25){
                VStack{
                    HStack{
                        Text(circle.title)
                            .font(.system(size: 20))
                            .foregroundColor(Color(UIColor.label))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    /*
                    //VARR
                    Text(ProcessJson.extraFormatNum(value: Double(circle.variation)))
                        .font(.caption2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                     */
                }
                
                ZStack{
                    //__________ circles morphism
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color.clear, lineWidth: 10)
                        .frame(
                            width: (UIScreen.main.bounds.width - 150 + 20) / 2,
                            height: (UIScreen.main.bounds.width - 150 + 20) / 2)
                        .background(
                            Circle()
                                .outerNeumorphism(Color.statsFillColor)
                                .rotationEffect(.degrees(90)))
                    //__________ circles progress bar
                    Circle()
                        .trim(from: 0, to: (circle.currentData / circle.goal))
                        .stroke(
                            LinearGradient(Color("Color4"), Color("Color1")),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(
                            width: (UIScreen.main.bounds.width - 150) / 2,
                            height: (UIScreen.main.bounds.width - 150) / 2)
                    //__________ circles progress bar
                    //AAA 3
                    //Show non decimal value if raw insights
                    let value = StringFormatter.formatNum(value: Double(circle.currentData))
                    
                    Text(
                        rawInsights == true && circle.id == 1
                        ? Double(circle.currentData) <= 100
                        ? value.components(separatedBy: ".")[0]
                        : value
                        : rawInsights == true
                        ? value : value + " %")
                    
                        //.font(.system(size: 22))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(circle.color)
                        .rotationEffect(.init(degrees: 90))

                }
                .rotationEffect(.init(degrees: -90))
            }
        }
    }
    }
}

// Mono Circle
extension AnalyticsNew {
    var monoCirle: some View {
        VStack(){
            HStack(){
                Spacer()
                VStack(){
                    HStack{
                        let p = swiftUIData.processedJson?.avg2 ?? 0
                        let value = StringFormatter.formatNum(value: Double(p))
                        let text = rawInsights == true
                        ? Double(p) <= 100
                        ? value.components(separatedBy: ".")[0]
                        : value
                        : rawInsights == true ? value : value + " %"
                        
                        Text(text)
                            //.font(.system(size: 22))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("Color4"))
                    }
                }
                Spacer()
            }.padding(50)
        }
        .padding(50)
        .cornerRadius(15)
        .background(
            Circle()
                .outerNeumorphism(Color.statsFillColor))
    }
}

// Offline View
extension AnalyticsNew {
    var offlineView: some View {
        ZStack {
            Color.bgFillColor
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image(systemName: "wifi.slash")
                    .font(.system(size:56))
                Text(Strings.notConnected)
            }
        }
    }
}

// Unavailable Data View
extension AnalyticsNew {
    var loadingView: some View {
        ZStack {
            Color.bgFillColor
                .edgesIgnoringSafeArea(.all)
                    
            ActivityIndicatorView(isVisible: $loading, type: .rotatingDots)
                .foregroundColor(Color("customPurple"))
                .frame(width: 70, height: 70, alignment: .center)
            }
    }
}
