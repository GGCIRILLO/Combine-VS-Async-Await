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
                                Menu {
                                    
                                } label: {
                                    HStack(spacing:4){
                                        Text("Filter by")
                                        Image(systemName: "chevron.down")
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment:.trailing)
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
                //                do {
                //                    let newTeams = try await teamsVM.getTeams()
                //                    teams = newTeams.data
                //                } catch{
                //                    print(error)
                //                }
                loadData()
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
    
    func loadData() {
        if let fileURL = Bundle.main.url(forResource: "teamsPreview.json", withExtension: nil) {
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
    
    func backgroundLimitOffset(_ proxy: GeometryProxy)->CGFloat{
        let minY = proxy.frame(in: .scrollView).minY
        return minY<140 ? -minY + 140 : 0
    }
}

#Preview {
    ContentView()
}
