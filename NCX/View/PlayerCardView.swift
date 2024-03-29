//
//  PlayerCardView.swift
//  NCX
//
//  Created by Luigi Cirillo on 26/03/24.
//

import SwiftUI

struct PlayerCardView: View {
    var player: Player
    var body: some View {
        
        VStack {
            HStack{
                VStack(alignment: .leading){
                    Text(player.firstName)
                    Text(player.lastName)
                        .bold()
                }
                .font(.title2)
                Spacer()
                VStack{
                    Text(player.height + " ft")
                    Text(player.weight + " kg")
                }
                .foregroundStyle(.gray)
                .font(.subheadline.bold())
                
                HStack {
                    Text(player.jerseyNumber ?? "ND" )
                    Text(player.position)
                }
                .font(.title)
            }
            .foregroundStyle(.black)
            Divider()
        }
        
    }
}

#Preview {
    PlayerCardView(player: Player(id:2, firstName:"Jaylen", lastName:"Adams", position:"G", height:"6-0", weight:"225", jerseyNumber:"10", college:"St. Bonaventure", country:"USA", draftYear:nil, draftRound:nil, draftNumber:nil, team: Team(id: 1, abbreviation: "ATL", city: "Atlanta", conference: "East", division: "SE", fullName: "Atlanta hawks", name: "Hawks")))
}
