//
//  TeamCardView.swift
//  NCX
//
//  Created by Luigi Cirillo on 25/03/24.
//

import SwiftUI

struct TeamCardView: View {
    var team : Team
    var body: some View {
        GeometryReader{
            let rect = $0.frame(in: .scrollView(axis: .vertical))
            let minY = rect.minY
            let topValue: CGFloat = 75.0
            
            let offset = min(minY - topValue, 0)
            let progress = max(min(-offset/topValue, 1), 0)
            let scale: CGFloat = 1+progress
            
            ZStack{
                Rectangle()
                    .fill(colorForTeam(teamName: team.fullName) ?? Color.green)
                    .overlay(alignment: .leading){
                        Image(team.abbreviation)
                            .scaleEffect(1.2, anchor: .topLeading)
                            .offset(x: -50, y: -40)
            
                    }
                    .overlay{
                        Rectangle()
                            .fill(.black.opacity(0.4))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .scaleEffect(scale, anchor: .bottom)
                
                VStack(alignment: .leading, spacing: 4, content: {
                    Spacer()
                    Text(team.abbreviation)
                        .font(.title3)
                    Text(team.fullName)
                        .font(.title.bold())
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)
                .offset(y: progress * -25)
            }
            .offset(y: -offset)
            .offset(y: progress * -topValue)
            
        }
        .foregroundStyle(.white)
        .padding(15)
    }
    func colorForTeam(teamName: String) -> Color? {
        switch teamName {
        case "Atlanta Hawks": return Color.red
        case "Boston Celtics": return Color.green
        case "Brooklyn Nets": return Color.black
        case "Charlotte Hornets": return Color(red: 29/255, green: 17/255, blue: 96/255)
        case "Chicago Bulls": return Color.red
        case "Cleveland Cavaliers": return Color(red: 128/255, green: 0/255, blue: 0/255)
        case "Dallas Mavericks": return Color.blue
        case "Denver Nuggets": return Color.yellow
        case "Detroit Pistons": return Color.red
        case "Golden State Warriors": return Color.yellow
        case "Houston Rockets": return Color.red
        case "Indiana Pacers": return Color.yellow
        case "LA Clippers": return Color(red: 0/255, green: 123/255, blue: 167/255)
        case "Los Angeles Lakers": return Color.purple
        case "Memphis Grizzlies": return Color.blue
        case "Miami Heat": return Color.red
        case "Milwaukee Bucks": return Color.green
        case "Minnesota Timberwolves": return Color.blue
        case "New Orleans Pelicans": return Color.blue
        case "New York Knicks": return Color.orange
        case "Oklahoma City Thunder": return Color.blue
        case "Orlando Magic": return Color.blue
        case "Philadelphia 76ers": return Color.blue
        case "Phoenix Suns": return Color.orange
        case "Portland Trail Blazers": return Color.black
        case "Sacramento Kings": return Color.purple
        case "San Antonio Spurs": return Color.black
        case "Toronto Raptors": return Color.red
        case "Utah Jazz": return Color.yellow
        case "Washington Wizards": return Color.blue
        default: return nil
        }
    }
}

#Preview {
    TeamCardView(team: Team(id: 1, abbreviation: "ATL", city: "Atlanta", conference: "east", division: "southeast", fullName: "Atlanta Hawks", name: "ATL"))
}
