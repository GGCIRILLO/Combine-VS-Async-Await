//
//  PlayerModel.swift
//  NCX
//
//  Created by Luigi Cirillo on 26/03/24.
//

import Foundation

struct Player: Codable, Identifiable, Hashable {
    let id: Int
    let firstName: String
    let lastName: String
    let position: String
    let height: String
    let weight: String
    let jerseyNumber: String?
    let college: String
    let country: String
    let draftYear: Int?
    let draftRound: Int?
    let draftNumber: Int?
    let team: Team
    
    private enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case jerseyNumber = "jersey_number"
        case draftYear = "draft_year"
        case draftRound = "draft_round"
        case draftNumber = "draft_number"
        case id, position, height, weight, college, country, team
    }
    
    // func to make it hashable
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id && lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName
    }
}

// Define a wrapper struct to represent the root JSON object

struct PlayersModel: Codable {
    let data: [Player]
    let meta: Meta
}

struct Meta: Codable {
    let next_cursor: Int
    let per_page: Int
}

