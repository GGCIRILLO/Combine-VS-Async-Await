//
//  PlayerCardView.swift
//  NCX
//
//  Created by Luigi Cirillo on 26/03/24.
//

import SwiftUI

struct PlayerCardView: View {
    var body: some View {
        HStack{
            VStack{
                Text("First name")
                Text("Last name")
                    .bold()
            }
            .font(.title2)
            Spacer()
            VStack{
                Text("height")
                Text("weight")
            }
            .foregroundStyle(.gray)
            .font(.subheadline.bold())
            Text("10")
                .font(.system(size: 45))
            Text("G-F")
                .font(.system(size: 45))
        }
    }
}

#Preview {
    PlayerCardView()
}
