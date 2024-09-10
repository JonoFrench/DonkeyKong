//
//  BonusBoxView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 12.08.24.
//

import SwiftUI

struct BonusBoxView: View {
    @EnvironmentObject var manager: GameManager
#if os(iOS)
    static var levelTextSize:CGFloat = 14
    static var bonusTextSize:CGFloat = 12
    static var frameWidth = 100.0
    static var frameHeight = 60.0
    static var bottomPadding = 6.0
#elseif os(tvOS)
    static var levelTextSize:CGFloat = 28
    static var bonusTextSize:CGFloat = 24
    static var frameWidth = 200.0
    static var frameHeight = 120.0
    static var bottomPadding = 12.0
#endif

    var body: some View {
        ZStack {
            VStack {
                Text("L=\(String(format: "%02d", manager.gameScreen.level))")
                    .foregroundStyle(.blue)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: BonusBoxView.levelTextSize))
                    .frame(maxWidth: BonusBoxView.frameWidth, alignment: .leading)
                    Image("BonusBox")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: BonusBoxView.frameWidth, height: BonusBoxView.frameHeight,alignment: .bottom)
                        .overlay(alignment: .bottom, content: {

                            Text("\(String(format: "%04d", manager.bonus))")
                                .foregroundStyle(.cyan)
                                .font(.custom("DonkeyKongClassicsNESExtended", size: BonusBoxView.bonusTextSize))
                                .padding(.bottom, BonusBoxView.bottomPadding)
                        })
            }
        }.background(.black)
    }
}

#Preview {
    let previewEnvObject = GameManager()
    return BonusBoxView()
        .environmentObject(previewEnvObject)
}
