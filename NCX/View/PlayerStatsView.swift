//
//  PlayerStatsView.swift
//  NCX
//
//  Created by Luigi Cirillo on 27/03/24.
//

import SwiftUI

struct PlayerStatsView: View {
    var playerID: Int
    @State private var statsVM = StatsVM()
    @State private var stats : [Stats] = []
    var body: some View {
        let stat = stats.first
        
        Text("OOpss... we're sorry, we could not find the stats average for this player")
            .font(.largeTitle.bold())
            .foregroundStyle(.gray)
            .task {
                do {
                    let newStats = try await statsVM.getStats(season: 2023, forPlayer: playerID)
                    stats = newStats
                    print(stats)
                } catch {
                    print(error)
                }
            }
    }
}

#Preview {
    PlayerStatsView(playerID: 15)
}
