//
//  StatsModel.swift
//  NCX
//
//  Created by Luigi Cirillo on 26/03/24.
//

import Foundation

struct Stats: Codable {
    let pts: Double
    let ast: Double
    let turnover: Double
    let pf: Double
    let fga: Double
    let fgm: Double
    let fta: Double
    let ftm: Double
    let fg3a: Double
    let fg3m: Double
    let reb: Double
    let oreb: Double
    let dreb: Double
    let stl: Double
    let blk: Double
    let fgPct: Double
    let fg3Pct: Double
    let ftPct: Double
    let min: String
    let gamesPlayed: Int
    let playerId: Int
    let season: Int
    
    enum CodingKeys: String, CodingKey {
        case pts, ast, turnover, pf, fga, fgm, fta, ftm, fg3a, fg3m, reb, oreb, dreb, stl, blk, fgPct = "fg_pct", fg3Pct = "fg3_pct", ftPct = "ft_pct", min, gamesPlayed = "games_played", playerId = "player_id", season
    }
}

struct StatsModel: Codable {
    let data : [Stats]
}
