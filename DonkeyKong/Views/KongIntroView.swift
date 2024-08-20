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
            ScreenView()
            KongView(kong: manager.kong)
                .position(manager.kong.kongPosition)
                .zIndex(2.0)
            PaulineView(pauline: manager.pauline)
                        .position(manager.pauline.paulinePosition)
                        .zIndex(1.9)
        }
    }
}
