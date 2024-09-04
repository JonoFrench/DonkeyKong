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
//                if kong.state == .intro || kong.state == .jumpingup || kong.state == .bouncing || kong.state == .sitting || kong.state == .dying || kong.state == .dead{
                    Image(kong.currentFrame)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: kong.frameSize.width, height: kong.frameSize.height)
                        .background(.clear)
//                }
                
            }.background(.clear)
                .frame(width: 1,height: 1,alignment: .center)
    }
}
