//
//  TeamsModel.swift
//  NCX
//
//  Created by Luigi Cirillo on 24/03/24.
//

import Foundation

struct TeamsModel: Codable {
    var data: [Team]
}

struct Team: Codable, Identifiable {
    var id: Int
    var abbreviation: String
    var city: String
    var conference: String
    var division: String
    var fullName: String
    var name: String
    
    private enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case id, abbreviation, city, conference, division, name
    }
}


