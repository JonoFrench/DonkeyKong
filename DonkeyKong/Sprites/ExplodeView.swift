//
//  ExplodeView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 25.08.24.
//

import SwiftUI

struct ExplodeView: View {
    @ObservedObject var explode:Explode
    var body: some View {
        ZStack {
            Image(explode.currentFrame)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: explode.frameSize.width, height: explode.frameSize.height)
                .background(.clear)
                .zIndex(2.1)
        }.background(.clear)
            .frame(width: 1,height: 1,alignment: .center)
    }
}
