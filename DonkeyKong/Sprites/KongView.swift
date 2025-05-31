//
//  KongView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 16.08.24.
//

import SwiftUI

struct KongView: View {
    @ObservedObject var kong:Kong
    var body: some View {
        ZStack {
            Image(kong.currentFrame)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: kong.frameSize.width, height: kong.frameSize.height)
                .background(.clear)
        }.background(.clear)
            .frame(width: 1,height: 1,alignment: .center)
    }
}
