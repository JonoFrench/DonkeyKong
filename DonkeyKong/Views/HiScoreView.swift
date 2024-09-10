//
//  HiScoreView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import SwiftUI

struct HiScoreView: View {
    @EnvironmentObject var manager: GameManager
    
#if os(iOS)
    static var titleTextSize:CGFloat = 24
    static var scoreTextSize:CGFloat = 24
    static var starttextSize:CGFloat = 14
#elseif os(tvOS)
    static var titleTextSize:CGFloat = 48
    static var scoreTextSize:CGFloat = 36
    static var starttextSize:CGFloat = 28
#endif
    var body: some View {
        let scores = manager.hiScores
        VStack {
            Spacer()
            Text("High Scores")
                .foregroundStyle(.red)
                .font(.custom("DonkeyKongClassicsNESExtended", size: HiScoreView.titleTextSize))
            Spacer()
            ForEach(scores.hiScores, id: \.self) {score in
                HStack{
                    Spacer()
                    Text("\(score.initials!)")
                        .foregroundStyle(.white)
                        .font(.custom("DonkeyKongClassicsNESExtended", size: HiScoreView.scoreTextSize))
                        .padding([.leading])
                    Spacer()
                    Text("\(String(format: "%06d", score.score))")
                        .foregroundStyle(.white)
                        .font(.custom("DonkeyKongClassicsNESExtended", size: HiScoreView.scoreTextSize))
                        .padding([.trailing])
                    Spacer()
                }
            }
            Spacer()
            Text(AppConstant.startText)
                .foregroundStyle(.red)
                .font(.custom("DonkeyKongClassicsNESExtended", size: HiScoreView.starttextSize))

        }.background(.black)
    }
}

#Preview {
    let previewEnvObject = GameManager()
    return HiScoreView()
        .environmentObject(previewEnvObject)
    
}
