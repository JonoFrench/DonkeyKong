//
//  PieView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 3.09.24.
//

import SwiftUI

struct PieView: View {
    @ObservedObject var pie:Pie
    var body: some View {
        ZStack {
            Image(pie.currentFrame)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: pie.frameSize.width, height: pie.frameSize.height)
                .background(.clear)
                .zIndex(2.1)
        }.background(.clear)
            .frame(width: 1,height: 1,alignment: .center)
            .position(pie.position)
    }
}
