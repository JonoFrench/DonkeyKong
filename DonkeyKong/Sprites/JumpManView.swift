//
//  ImageView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 12.08.24.
//

import SwiftUI

struct JumpManView: View {
    @ObservedObject var jumpMan:JumpMan
    var body: some View {
        ZStack {
            if jumpMan.facing == .right {
                Image(jumpMan.currentFrame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: jumpMan.frameSize.width, height: jumpMan.frameSize.height)
                    .rotationEffect(Angle(degrees: 180))
                    .background(.clear)
                    .scaleEffect(CGSize(width: 1, height: -1))
//                    .overlay(alignment: .center, content: {
//                        Circle()
//                            .fill(Color.yellow)
//                            .frame(width: jumpMan.frameSize.width / 2, height: jumpMan.frameSize.height / 2)
//                            .zIndex(2.1)
//                    })
            } else {
                Image(jumpMan.currentFrame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: jumpMan.frameSize.width, height: jumpMan.frameSize.height)
                    .background(.clear)
//                    .overlay(alignment: .center, content: {
//                        Circle()
//                            .fill(Color.yellow)
//                            .frame(width: jumpMan.frameSize.width / 2, height: jumpMan.frameSize.height / 2)
//                            .zIndex(2.1)
//                    })
            }
        }.background(.clear)
    }
}
