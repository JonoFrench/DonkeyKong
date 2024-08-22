//
//  BarrelView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 20.08.24.
//

import SwiftUI

struct BarrelView: View {
    @ObservedObject var barrel:Barrel
    var body: some View {
        ZStack {
            Image(barrel.currentFrame)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: barrel.frameSize.width, height: barrel.frameSize.height)
                .background(.clear)
                .zIndex(2.1)
        }.background(.clear)
            .frame(width: 1,height: 1,alignment: .center)
    }
}
