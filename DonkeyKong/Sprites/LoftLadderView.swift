//
//  LoftLadderView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 3.09.24.
//

import SwiftUI

struct LoftLadderView: View {
    @ObservedObject var ladder:LoftLadder
    var body: some View {
        ZStack {
            Image(ladder.currentFrame)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: ladder.frameSize.width, height: ladder.frameSize.height)
                .background(.clear)
                .zIndex(2.1)
                .overlay(alignment: .center, content: {
                    Image(ladder.currentFrame)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: ladder.frameSize.width, height: ladder.frameSize.height)
                        .background(.clear)
                        .zIndex(2.1)
                        .offset(y:ladder.offset)
                        .overlay(alignment: .center, content: {
                            Image(ladder.currentFrame)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: ladder.frameSize.width, height: ladder.frameSize.height)
                                .background(.clear)
                                .zIndex(2.1)
                                .offset(y:ladder.offset * 2)
                        })
                })
        }.background(.clear)
            .frame(width: 1,height: 1,alignment: .center)
    }
}
