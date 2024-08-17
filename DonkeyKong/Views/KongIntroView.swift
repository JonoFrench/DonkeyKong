//
//  KongIntroView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 16.08.24.
//

import SwiftUI

struct KongIntroView: View {
    @EnvironmentObject var manager: GameManager
    var body: some View {
        ZStack {
            ForEach(0..<28) { y in
                ForEach(0..<30) { x in
                    let ir = manager.screenData[y][x]
                    if ir.assetType != .blank {
                        Image(ir.assetImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: manager.assetDimention, height: manager.assetDimention)
                            .position(x:Double(x) * manager.assetDimention + (manager.assetDimention / 2),y: Double(y) * manager.assetDimention - (manager.assetOffset * ir.assetOffset) + 80)
                            .zIndex(ir.assetType == .ladder ? -0.20 : -0.10)
                    }
                }
            }
        }.zIndex(0.1)
        ZStack {
            KongView(kong: manager.kong)
                .position(manager.kong.kongPosition)
                .zIndex(2.0)
                    PaulineView(pauline: manager.pauline)
                        .position(manager.pauline.paulinePosition)
                        .zIndex(1.9)
        }
    }
}

//#Preview {
//    KongIntroView()
//}
