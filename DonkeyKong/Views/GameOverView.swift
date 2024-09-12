//
//  GameOverView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 12.09.24.
//

import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var manager: GameManager
#if os(iOS)
    static var textSize:CGFloat = 14
#elseif os(tvOS)
    static var textSize:CGFloat = 28
#endif

    var body: some View {
        Rectangle()
            .fill(.blue)
            .frame(width: manager.gameScreen.gameSize.width / 1.50,height: manager.gameScreen.gameSize.width / 1.50,alignment: .center)
            .overlay(alignment: .center, content: {
                Text("GAME OVER")
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: GameOverView.textSize))
           })
    }
}

#Preview {
    GameOverView()
}
