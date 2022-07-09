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
    
    //
    @ObservedObject var swiftUIData = ANewVCDataSUI()
    
    //
    @State private var showingAlert = false
    
    //Dismiss the view
    @Environment(\.presentationMode) var presentationMode
    
    //Network Status
    @ObservedObject var monitor = NetworkMonitor()
    
    //
    @State var selected = 0
    var colors = [Color("Color1"),Color("Color")]
    var columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    
    //
    @State var titles = ["Engagement","Reach","Impressions"]
    @State var subtitles = [" "," "," "]
    @State var infoTitles = ["Engagement Rate (ER)","Engagement Rate by Reach (ERR)", "Engagement Rate by Impressions (ER Impressions)"]
    @State var infoMessages =
        ["Engagement = Likes + Comments\n\nEngagement is a metric used to determine the number of interactions your content receives.",
                               
         "\nReach is the total number of people (single accounts) who saw your content.",
                               
         "\nImpressions represents how many times your content appeared on a screen, no matter if it was clicked or not."]
    
    
    
    @State var loading = true
    
    //Layout
    @State var padCst = UIScreen.main.bounds.size.width < 375 ? 0 : 17.5
    
    //Toggle button
    @State private var isToggled = false
    
    init() {
        //Navigation bar customization
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.clear]
                
    }
    
    
//MARK: - Body
    var body: some View{
        
    ZStack {
    Color.bgFillColor.ignoresSafeArea()
            
//MARK: - Screen selection
    VStack(){
                
        //AKK /* start
        // /*
        
        
//MARK: - Header
        HStack {
            
            VStack(alignment: .leading, spacing: 5) {
            
                Text("Analytics")
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
                ANewVCDataSUI.lastSelected = 0
            }) {
                Image(systemName: "chevron.down.circle")
                    .font(Font.system(.title))
                    .foregroundColor(Color(UIColor.label))
            }
        }
        .padding()
                
//Screen when offline
        if monitor.isConnected == false {
                    
            ZStack {
                Color.bgFillColor
                    .edgesIgnoringSafeArea(.all)
                            
                VStack {
                    Image(systemName: "wifi.slash")
                        .font(.system(size:56))
                    Text("Not connected")
                }
                        
            }
                
//Screen when loading Json data
        } else if swiftUIData.jsonOfficial == nil {
               
            ZStack {
                Color.bgFillColor
                    .edgesIgnoringSafeArea(.all)
                        
                ActivityIndicatorView(isVisible: $loading, type: .rotatingDots)
                    .foregroundColor(Color("customPurple"))
                    .frame(width: 70, height: 70, alignment: .center)
                }
                    
//Screen when data is available
        } else {
                    
            //Screen when profile is private (unofficial Json)
            if swiftUIData.processedJson?.isPv == true {
                        
                ZStack {
                    Color.bgFillColor
                        .edgesIgnoringSafeArea(.all)
                    Text("Profile is private")
                }
             
            //Screen when data is invalid
            } else if swiftUIData.processedJson?.rates == Optional([]) {
                            
                ZStack {
                    Color.bgFillColor
                        .edgesIgnoringSafeArea(.all)
                    if swiftUIData.processedJson?.usr != nil {
                        Text("No media have been posted yet\nas a Business/Creator account")
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Data unavailable\n\nOr\n\nLikely no new posts\nas a Business/Creator account")
                            .multilineTextAlignment(.center)
                    }
                }
                       
            //Screen when data is available
            } else {
            //*/
            //AKK */ End
                
                
                
                
                

                
//MARK: - ScrollView - Start
                ScrollView(.vertical, showsIndicators: false) {
                            
                        


                    //MARK: - Circles part
                    VStack(alignment: .leading, spacing: 25) {

                                    
                                    
//MARK: - Circles part - header
                                    
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
                                    Image(systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up")
                                        .foregroundColor(Color("Color4"))
                                    
                                }
                                
                                .toggleStyle(DarkToggleStyle())
                                .padding(.trailing,10)
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
                                            
                  
        
//MARK: - Circles part - Circles
                        //Only 1 post
                        
                        if swiftUIData.processedJson?.rates.count == 1 {
                            let p = swiftUIData.processedJson?.avg2 ?? 0
                            let value = ProcessJson.formatNum(value: Double(p))
                            let text = rawInsights == true ? Double(p) <= 100 ? value.components(separatedBy: ".")[0] : value
                                     : rawInsights == true ? value : value + " %"
                                 
                            VStack(){
                                HStack(){
                                    Spacer()
                                    VStack(){
                                        HStack{
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
                                    
                                    .outerNeumorphism(Color.statsFillColor)
                            )
                            
                            
                            
                            
                            
                            
                            
                        //More then 1 post
                            
                        } else {
                        
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
                                        
                                        //VARR
                                        Text(ProcessJson.extraFormatNum(value: Double(circle.variation)))
                                            .font(.caption2)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    
                                    
                                    
                                    
                                    
                                    ZStack{
                                
                                        //__________ circles morphism
                                        
                                        Circle()
                                            .trim(from: 0, to: 1)
                                            .stroke(Color.clear, lineWidth: 10)
                                            .frame(width: (UIScreen.main.bounds.width - 150 + 20) / 2, height: (UIScreen.main.bounds.width - 150 + 20) / 2)
                                            .background(
                                                Circle()
                                                    .outerNeumorphism(Color.statsFillColor)
                                                    .rotationEffect(.degrees(90))
                                            )
                                        
                                        
                                            
                                            
                                            
                                        //__________ circles progress bar
            
                                        Circle()
                                            .trim(from: 0, to: (circle.currentData / circle.goal))
                                            .stroke(LinearGradient(Color("Color4"), Color("Color1")),
                                                    style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                            .frame(width: (UIScreen.main.bounds.width - 150) / 2, height: (UIScreen.main.bounds.width - 150) / 2)
                                            
                                        
                                        
                                        
            
                                        //__________ circles progress bar
                                        //AAA 3
                                        //Show non decimal value if raw insights
                                        let value = ProcessJson.formatNum(value: Double(circle.currentData))
                                        
                                        Text( rawInsights == true && circle.id == 1 ?
                                                Double(circle.currentData) <= 100 ? value.components(separatedBy: ".")[0] : value
                                                : rawInsights == true ? value : value + " %"
                                            
                                        )
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
           
                                    
//MARK: - Circles part - Bar Chart
                        //Only show if there is more than 1 post
                        if swiftUIData.processedJson?.rates.count != 1 {
                        HStack(spacing: 10){

                            ForEach(swiftUIData.graph_Data ?? []){value in
    
                                // Bars...
                                VStack{
                                    VStack{
                                        Spacer(minLength: 0)
                                        
                                        if selected == value.id{
                                            
                                        }
            
                                        RoundedShape()
                                            .fill(
                                                
                                                
                                                LinearGradient(gradient: .init(colors: selected == value.id ? colors : [Color(UIColor.label).opacity(0.06)]), startPoint: .top, endPoint: .bottom)
                                                     )
                                            
                                            // max height = 50
                                            .frame(height: value.barHeight)

                                    }
                                    .frame(height: 60)
                                    //100) //50+10
                                    .onTapGesture {
                                        withAnimation(.easeOut){
                                            selected = value.id
                                            let _ = updateCircle(v1:value.r,v2:value.rVr)
                                            ANewVCDataSUI.lastSelected = value.id
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
                            
                        HStack {
                            let num = swiftUIData.processedJson?.rates.count
                            if num != 1 {
                            Image(systemName: "circle")
                                .font(.caption)
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                            Text("Latest")
                                .font(.caption)
                                .foregroundColor(Color(UIColor.label).opacity(0.6))
                            }
                            Spacer()
                            
                            
                            let text2 = num != 1 ? "Last \(num ?? 0) Posts" : "Last post"
                            Text(text2)
                                .font(.caption)
                                .foregroundColor(Color(UIColor.label).opacity(0.6))

                        }
                                
                    }
                    .padding()
                    .cornerRadius(10)
                    .padding(EdgeInsets(top: 0, leading: CGFloat(padCst), bottom: 0, trailing: CGFloat(padCst)))
                                
            
            
                    //MARK: - Stats part
                                
            
                    // stats Grid....
                    LazyVGrid(columns: columns,spacing: 30){
                        ForEach(swiftUIData.stats_Data){stat in
     
                            //ZStack{
                            VStack(spacing: 20){
            
                                HStack{
                                    Text(swiftUIData.processedJson?.rates.count == 1 ? "" : "Average")
                                        .font(.body)
                                        //.font(.system(size: 20))
                                        //.fontWeight(.bold)
                                        .foregroundColor(Color(UIColor.label))
                
                                    Spacer(minLength: 0)
                
                                    stat.image
                                        .font(Font.system(.title2))
                                
                                }
            
                                Text(stat.currentData)
                                    .font(.system(size: 22))
                                    .foregroundColor(Color(UIColor.label))
                                    .fontWeight(.bold)
                
                                Text(stat.title)
                                    //.font(.system(size: 22))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(UIColor.label))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    //Spacer(minLength: 0)
                                    //Spacer()
                                
            
                            }
                            .padding()
                            
                            //.background(Color(UIColor.label).opacity(0.06))
                            .cornerRadius(15)
                            
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    
                                    .outerNeumorphism(Color.statsFillColor)
                            )

                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .padding(.bottom,30)
                            
                            
                } //ScrollView - End

            } //AKK
        } //AKK
                
    }
    }
    }
    
    

    
    
    
//MARK: - Functions
    
    //AAA - Just a function to print out values
    func printdd (value:Bool) -> Bool {
        print(value)
        return true
    }
    
    //AAA 2
    func updateCircle (v1:CGFloat,v2:CGFloat) -> Bool {
        swiftUIData.circles_Data[1].currentData = CGFloat(v1)
        swiftUIData.circles_Data[1].variation = v2
        return true
    }
    
    func updateLabels () -> Bool {
        titles = rawInsights == true ? ["Engagement","Reach","Impressions"] : ["Engagement","Engagement","Engagement"]
        subtitles = rawInsights == true ? [" "," "," "] : ["Per Follower","By Reach", "By Impressions"]
        
        
        infoTitles = rawInsights == true ? ["Engagement","Reach", "Impressions"] : ["Engagement Rate (ER)","Engagement Rate by Reach (ERR)", "Engagement Rate by Impressions (ER Impressions)"]
            
        infoMessages = rawInsights == true ?
        ["\nEngagement is a metric used to determine the number of interactions. your content receives\n\nEngagement = Likes + Comments",
         
         "\nReach is the total number of people (single accounts) who saw your content.",
         
         "\nImpressions represents how many times your content appeared on a screen, no matter if it was clicked or not."] :
            
        ["\nER = Likes and Comments / Followers * 100\n\nEngagement Rate is a metric used to determine the number of interactions your content receives, proportionally to your followers.",
                
        "\nERR = Likes and Comments / Reach * 100\n\nERR is more accurate than an Engagement Rate on a follower basis since not all them will see your posts, and some non-followers may see your posts through shares or hashtags.",
                
        "\nER impressions = Likes and Comments / Impressions *100\n\nIf your ER impressions is lower than your ERR, then it is a good sign, as your content is viewed multiple times."]
        
        
        
        return true
    }
    
  
}


//MARK: - Elements

// graph Data...
struct Post : Identifiable {
    var id : Int
    var post : String
    var r : CGFloat
    var barHeight: CGFloat
    var rVr: CGFloat
}

struct RoundedShape : Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 5, height: 5))
        return Path(path.cgPath)
    }
}
