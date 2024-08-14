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
        ///Always at the back
        
    }
}

//#Preview {
//    let previewEnvObject = GameManager()
//    return ScreenView()
//        .environmentObject(previewEnvObject)
//}
