//
//  ScreenView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 12.08.24.
//

import SwiftUI

///The basic screen of girders, ladders etc

struct ScreenView: View {
    @EnvironmentObject var manager: GameManager
    @ObservedObject var gameScreen: ScreenData
    var body: some View {
        ZStack(alignment: .center)  {
            ForEach(0..<gameScreen.screenDimensionY, id: \.self) { y in
                ForEach(0..<gameScreen.screenDimensionX, id: \.self) { x in
                    let ir = gameScreen.screenData[y][x]
                    if ir.assetType != .blank && ir.assetType != .blankLadder {
                        Image(ir.assetImage(level: gameScreen.level))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: gameScreen.assetDimension, height: gameScreen.assetDimension)
                            .position(x:Double(x) * gameScreen.assetDimension + (gameScreen.assetDimension / 2),y: Double(y) * gameScreen.assetDimension - (gameScreen.assetDimensionStep * ir.assetOffset) + 80)
                            .zIndex(ir.assetZOrder())
                    }
                }
            }
        }.zIndex(0.1)
            .background(.black)
        ///Always at the back
        
    }
}

//#Preview {
//    let previewEnvObject = GameManager()
//    return ScreenView()
//        .environmentObject(previewEnvObject)
//}
