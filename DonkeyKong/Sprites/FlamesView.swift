//
//  FlamesView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 18.08.24.
//

import SwiftUI

struct FlamesView: View {
    @ObservedObject var flames:Flames
    var body: some View {
            ZStack {
                    if flames.isLeft {
                        Image(flames.currentFrame)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: flames.frameSize.width, height: flames.frameSize.height)
                            .rotationEffect(Angle(degrees: 180))
                            .background(.clear)
                            .scaleEffect(CGSize(width: 1, height: -1))
                    } else {
                        Image(flames.currentFrame)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: flames.frameSize.width, height: flames.frameSize.height)
                            .background(.clear)

                    }
            }.background(.clear)
                .frame(width: 1,height: 1,alignment: .center)
        }
}
