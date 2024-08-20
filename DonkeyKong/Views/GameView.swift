//
//  GameView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 12.08.24.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var manager: GameManager
    @ObservedObject var jumpMan:JumpMan
    var body: some View {
        ZStack {
            ScreenView()
                .position(x:manager.gameSize.width / 2,y:manager.gameSize.height / 2)
                .zIndex(0.1)
            BonusBoxView()
                .position(x:manager.gameSize.width - 80,y:60)
            JumpManView(jumpMan: manager.jumpMan)
                .position(manager.jumpMan.position)
                .zIndex(2.0)
            KongView(kong: manager.kong)
                .position(manager.kong.position)
                .zIndex(2.0)
            PaulineView(pauline: manager.pauline)
                .position(manager.pauline.position)
                .zIndex(1.9)
            FlamesView(flames: manager.flames)
                .position(manager.flames.position)
                .zIndex(1.9)
            ForEach(manager.collectibles, id: \.id) { collectible in
                CollectiblesView(collectible: collectible)
                    .position(collectible.position)
            }
            
        }.zIndex(1.0)
    }
}

//#Preview {
//    let previewEnvObject = GameManager()
//    return GameView()
//        .environmentObject(previewEnvObject)
//}
