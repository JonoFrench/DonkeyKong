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
//                .overlay(alignment: .center, content: {
//                    Circle()
//                        .fill(Color.yellow)
//                        .frame(width: barrel.frameSize.width / 2, height: barrel.frameSize.height / 2)
//                        .zIndex(2.1)
//                        .offset(y:-barrel.frameSize.height)
//                })
        }.background(.clear)
            .frame(width: 1,height: 1,alignment: .center)
    }
}
