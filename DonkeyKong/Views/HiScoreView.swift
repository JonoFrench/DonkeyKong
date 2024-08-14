//
//  HiScoreView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import SwiftUI

struct HiScoreView: View {
    @EnvironmentObject var manager: GameManager
    var body: some View {
        let scores = manager.hiScores
        VStack {
            Spacer()
            Text("High Scores")
                .foregroundStyle(.red)
                .font(.custom("DonkeyKongClassicsNESExtended", size: 24))
            Spacer()
            ForEach(scores.hiScores, id: \.self) {score in
                HStack{
                    Spacer()
                    Text("\(score.initials!)")
                        .foregroundStyle(.white)
                        .font(.custom("DonkeyKongClassicsNESExtended", size: 24))
                        .padding([.leading])
                    Spacer()
                    Text("\(String(format: "%06d", score.score))")
                        .foregroundStyle(.white)
                        .font(.custom("DonkeyKongClassicsNESExtended", size: 24))
                        .padding([.trailing])
                    Spacer()
                }
            }
            Spacer()
            Text("Press Jump to Start")
                .foregroundStyle(.red)
                .font(.custom("DonkeyKongClassicsNESExtended", size: 14))

        }.background(.introBackground)
    }
}

#Preview {
    let previewEnvObject = GameManager()
    return HiScoreView()
        .environmentObject(previewEnvObject)
    
}
