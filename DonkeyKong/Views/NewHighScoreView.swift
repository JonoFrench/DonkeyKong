//
//  NewHighScoreView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 12.08.24.
//

import SwiftUI

struct NewHighScoreView: View {
    @ObservedObject var hiScores:DonkeyKongHighScores
    var body: some View {
        VStack {
            Spacer()
            Text("New High Score")
                .foregroundStyle(.red)
                .font(.custom("DonkeyKongClassicsNESExtended", size: 20))
            Spacer()
            Text("Enter your initials")
                .foregroundStyle(.white)
                .font(.custom("DonkeyKongClassicsNESExtended", size: 16))

            HStack {
                Spacer()
                Text(String(hiScores.letterArray[0]))
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: 38))
                    .padding() // Add some padding around the letter
                    .border(hiScores.letterIndex == 0 ? Color.red : Color.white , width: 2)
                Spacer()
                Text(String(hiScores.letterArray[1]))
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: 38))
                    .padding() // Add some padding around the letter
                    .border(hiScores.letterIndex == 1 ? Color.red : Color.white, width: 2)
                Spacer()
                Text(String(hiScores.letterArray[2]))
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: 38))
                    .padding() // Add some padding around the letter
                    .border(hiScores.letterIndex == 2 ? Color.red : Color.white, width: 2)
                Spacer()
                
            }
            Spacer()
            Text("Press Up / Down")
                .foregroundStyle(.red)
                .font(.custom("DonkeyKongClassicsNESExtended", size: 12))
            Spacer()
            Text("Jump to select")
                .foregroundStyle(.red)
                .font(.custom("DonkeyKongClassicsNESExtended", size: 12))

            Spacer()
        }.background(.black)
    }
}

