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
        ZStack {
            ForEach(0..<gameScreen.screenDimentionY, id: \.self) { y in
                ForEach(0..<gameScreen.screenDimentionX, id: \.self) { x in
                    let ir = gameScreen.screenData[y][x]
                    if ir.assetType != .blank {
                        Image(ir.assetImage(level: manager.level))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: gameScreen.assetDimention, height: gameScreen.assetDimention)
                            .position(x:Double(x) * gameScreen.assetDimention + (gameScreen.assetDimention / 2),y: Double(y) * gameScreen.assetDimention - (gameScreen.assetOffset * ir.assetOffset) + 80)
                            .zIndex(ir.assetZOrder())
                    }
                }
            }
        }.zIndex(0.1)
        ///Always at the back
        
    }
}

//#Preview {
//    let previewEnvObject = GameManager()
//    return ScreenView()
//        .environmentObject(previewEnvObject)
//}
