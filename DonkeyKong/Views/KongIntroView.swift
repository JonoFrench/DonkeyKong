//
//  KongIntroView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 16.08.24.
//

import SwiftUI

struct KongIntroView: View {
    @ObservedObject var manager: GameManager
    @ObservedObject var kong:Kong
    var body: some View {
        ZStack {
            ScreenView(gameScreen: manager.gameScreen)
            KongView(kong: manager.kong)
                .position(manager.kong.position)
                .zIndex(2.0)
            PaulineView(pauline: manager.pauline)
                        .position(manager.pauline.position)
                        .zIndex(1.9)
        }
    }
}
