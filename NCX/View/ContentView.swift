//
//  ContentView.swift
//  NCX
//
//  Created by Luigi Cirillo on 24/03/24.
//

import SwiftUI

struct ContentView: View {
    @State private var teamsVM = TeamsVM()
    @State private var teams : [Team] = []
    @State private var activeCard : Int?
    
    @State private var playersVM = PlayersVM()
    @State private var players : [Player] = []
    
    @State private var statsVM = StatsVM()
    @State private var stats : StatsModel?
    
    @Environment (\.colorScheme) private var scheme
    
    var body: some View {
        NavigationView {
            VStack {
                if teams.isEmpty{
                    Spacer()
                    VStack {
                        ProgressView()
                            .scaleEffect(1, anchor: .center)
                            .progressViewStyle(CircularProgressViewStyle())
                        
                        Text("Loading...")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                else{
                    ScrollView(.vertical){
                        VStack(spacing: 0){
                            VStack(alignment: .leading, spacing: 15) {
                                Text("NBA Teams")
                                    .font(.largeTitle.bold())
                                    .frame(height: 45)
                                    .padding(.horizontal, 15)
                                
                                GeometryReader{
                                    let rect = $0.frame(in: .scrollView)
                                    let minY = rect.minY.rounded()
                                    
                                    
                                    ScrollView(.horizontal){
                                        LazyHStack(spacing: 0){
                                            ForEach(teams) { team in
                                                if team.id<=30 {
                                                    ZStack{
                                                        if minY==75.0{
                                                            //Not scrolled
                                                            TeamCardView(team: team)
                                                            
                                                        } else{
                                                            // Showing only selected card
                                                            if activeCard == team.id {
                                                                
                                                                TeamCardView(team: team)
                                                                
                                                            } else {
                                                                Rectangle()
                                                                    .fill(.clear)
                                                            }
                                                        }
                                                    }
                                                    .containerRelativeFrame(.horizontal)
                                                }
                                            }
                                        }
                                        .scrollTargetLayout()
                                    }
                                    .scrollPosition(id: $activeCard)
                                    .scrollTargetBehavior(.paging)
                                    .scrollClipDisabled()
                                    .scrollIndicators(.hidden)
                                    .scrollDisabled(minY != 75.0)
                                }
                                .frame(height: 200)
                            }
                            LazyVStack(spacing:15){
                                if players.isEmpty{
                                    ForEach(teams.shuffled()) { team in
                                        if team.id<=30{
                                            HStack(spacing:0){
                                                Text(team.name)
                                                    .bold()
                                                
                                                Spacer()
                                                Text(team.conference)
                                            }
                                            .font(.title3)
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 6)
                                        }
                                    }
                                } else {
//                                    ForEach(players, id: \.self) { player in
//                                    
//                                            HStack(spacing:0){
//                                                Text(player.firstName)
//                                                    .bold()
//                                                
//                                                Spacer()
//                                                Text(player.lastName)
//                                            }
//                                            .font(.title3)
//                                            .padding(.horizontal, 15)
//                                            .padding(.vertical, 6)
//                                        
//                                    }
                                }
                            }
                            .padding(15)
                            .mask({
                                Rectangle()
                                .visualEffect { content, proxy in
                                    content
                                        .offset(y: backgroundLimitOffset(proxy))
                                }
                            })
                            .background {
                                GeometryReader{
                                    let rect = $0.frame(in: .scrollView)
                                    let minY = min(rect.minY - 200, 0)
                                    let progress = max(min(-minY/30 , 1), 0)
                                    
                                    RoundedRectangle(cornerRadius: 30*progress, style: .continuous)
                                        .fill(scheme == .dark ? .black : .white)
                                        .visualEffect { content, proxy in
                                            content
                                                .offset(y: backgroundLimitOffset(proxy))
                                        }
                                }
                            }
                        }
                        .padding(.vertical, 15)
                    }
                    .scrollTargetBehavior(CustomScrollBehaviour())
                    .scrollIndicators(.hidden)
                }
            }
            .task {
//                                do {
//                                    let newTeams = try await teamsVM.getTeams()
//                                    teams = newTeams.data
//                                } catch{
//                                    print(error)
//                                }
                loadTeams(fileName: "teamsPreview.json")
                
                do{
                    let newPlayers = try await playersVM.getPlayers(forTeam: 1)
                    players = newPlayers
                    print(players)
                } catch {
                    print(error)
                }
                //loadTeams(fileName: "playersResponse.json")
                
//                do {
//                    let newStats = try await statsVM.getStats(season: 2023, forPlayer: 15)
//                    stats = newStats
//                    if let stats = stats{
//                        print(stats)
//                    } else {
//                        print("NOT found")
//                    }
//                } catch {
//                    print(error)
//                }
                do {
                    let playerStats = try loadPlayerStats(from: "stats.json")
                    print(playerStats)
                } catch {
                    print("Error loading player stats: \(error)")
                }
            }
            .onAppear{
                if activeCard == nil {
                    activeCard = 1
                }
            }
            .onChange(of: activeCard) { oldValue, newValue in
                withAnimation(.snappy){
                    // change players
                }
            }
        }
    }
    
    func loadTeams(fileName:String) {
        if let fileURL = Bundle.main.url(forResource: fileName, withExtension: nil) {
            do {
                let data = try Data(contentsOf: fileURL)
                let teamsData = try JSONDecoder().decode(TeamsModel.self, from: data)
                teams = teamsData.data
            } catch {
                print("Error loading data: \(error)")
            }
        } else {
            print("File not found")
        }
    }
    
    func loadPlayerStats(from filename: String) throws -> [Player] {
        // Get the URL for the JSON file
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: nil) else {
            throw NSError(domain: "File not found", code: 404, userInfo: nil)
        }
        
        // Load data from the file
        let data = try Data(contentsOf: fileURL)
        
        // Decode the JSON data into an array of PlayerStats objects
        let decoder = JSONDecoder()
        let playerStatsArray = try decoder.decode(PlayersModel.self, from: data)
        
        return playerStatsArray.data
    }
    
    func backgroundLimitOffset(_ proxy: GeometryProxy)->CGFloat{
        let minY = proxy.frame(in: .scrollView).minY
        return minY<140 ? -minY + 140 : 0
    }
}

#Preview {
    ContentView()
}
