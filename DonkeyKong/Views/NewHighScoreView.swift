//
//  NewHighScoreView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 12.08.24.
//

import SwiftUI

struct NewHighScoreView: View {
#if os(iOS)
    static var titleTextSize:CGFloat = 36
    static var subTitleTextSize:CGFloat = 28
    static var letterTextSize:CGFloat = 38
    static var starttextSize:CGFloat = 30
    static var infoTextSize:CGFloat = 18
#elseif os(tvOS)
    static var titleTextSize:CGFloat = 72
    static var subTitleTextSize:CGFloat = 56
    static var letterTextSize:CGFloat = 76
    static var starttextSize:CGFloat = 48
    static var infoTextSize:CGFloat = 36
#endif
    @ObservedObject var hiScores:DonkeyKongHighScores
    var body: some View {
        VStack {
            Spacer()
            Text("New High Score")
                .foregroundStyle(.red)
                .font(.custom("DonkeyKongClassicsNESExtended", size: NewHighScoreView.titleTextSize))
            Spacer()
            Text("Enter your initials")
                .foregroundStyle(.white)
                .font(.custom("DonkeyKongClassicsNESExtended", size: NewHighScoreView.subTitleTextSize))

            HStack {
                Spacer()
                Text(String(hiScores.letterArray[0]))
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: NewHighScoreView.letterTextSize))
                    .padding()
                    .border(hiScores.letterIndex == 0 ? Color.red : Color.white , width: 2)
                Spacer()
                Text(String(hiScores.letterArray[1]))
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: NewHighScoreView.letterTextSize))
                    .padding()
                    .border(hiScores.letterIndex == 1 ? Color.red : Color.white, width: 2)
                Spacer()
                Text(String(hiScores.letterArray[2]))
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: NewHighScoreView.letterTextSize))
                    .padding()
                    .border(hiScores.letterIndex == 2 ? Color.red : Color.white, width: 2)
                Spacer()
                
            }
            Spacer()
            Text("Press Up / Down")
                .foregroundStyle(.red)
                .font(.custom("DonkeyKongClassicsNESExtended", size: NewHighScoreView.infoTextSize))
            Spacer()
            Text("Jump to select")
                .foregroundStyle(.red)
                .font(.custom("DonkeyKongClassicsNESExtended", size: NewHighScoreView.infoTextSize))

            Spacer()
        }.background(.black)
    }
}

