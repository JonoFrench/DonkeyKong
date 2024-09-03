//
//  FireBlobView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 20.08.24.
//

import SwiftUI

struct FireBlobView: View {
    @ObservedObject var fireBlob:FireBlob
    var body: some View {
        ZStack {
            if fireBlob.direction == .right {
                Image(fireBlob.currentFrame)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: fireBlob.frameSize.width, height: fireBlob.frameSize.height)
                    .rotationEffect(Angle(degrees: 180))
                    .background(.clear)
                    .scaleEffect(CGSize(width: 1, height: -1))
            } else {
                Image(fireBlob.currentFrame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: fireBlob.frameSize.width, height: fireBlob.frameSize.height)
                    .background(.clear)
                    .zIndex(2.1)
            }
        }.background(.clear)
            .frame(width: 1,height: 1,alignment: .center)
    }
}
