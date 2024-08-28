//
//  NewHighScoreView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 12.08.24.
//

import SwiftUI

struct NewHighScoreView: View {
    @EnvironmentObject var manager: GameManager
    @State private var initialIndex = 0
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
            //Spacer()

            HStack {
                Spacer()
                Text(String(manager.hiScores.letterArray[0]))
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: 38))
                    .padding() // Add some padding around the letter
                    .border(manager.hiScores.letterIndex == 0 ? Color.red : Color.white , width: 2)
                Spacer()
                Text(String(manager.hiScores.letterArray[1]))
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: 38))
                    .padding() // Add some padding around the letter
                    .border(manager.hiScores.letterIndex == 1 ? Color.red : Color.white, width: 2)
                Spacer()
                Text(String(manager.hiScores.letterArray[2]))
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: 38))
                    .padding() // Add some padding around the letter
                    .border(manager.hiScores.letterIndex == 2 ? Color.red : Color.white, width: 2)
                Spacer()
                
            }
            Spacer()
            Text("Press Up / Down")
                .foregroundStyle(.red)
                .font(.custom("DonkeyKongClassicsNESExtended", size: 12))
            Text("Jump to select")
                .foregroundStyle(.red)
                .font(.custom("DonkeyKongClassicsNESExtended", size: 12))

            Spacer()
        }.background(.black)
    }
}

#Preview {
    let previewEnvObject = GameManager()
    return NewHighScoreView()
        .environmentObject(previewEnvObject)
    
}
