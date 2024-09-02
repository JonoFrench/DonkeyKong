//
//  ConveyorView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 2.09.24.
//

import SwiftUI

struct ConveyorView: View {
    @ObservedObject var conveyor:Conveyor
    var body: some View {
        ZStack {
            if conveyor.direction == .left {
                Image(conveyor.currentFrame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: conveyor.frameSize.width, height: conveyor.frameSize.height)
                    .rotationEffect(Angle(degrees: 180))
                    .background(.clear)
                    .scaleEffect(CGSize(width: 1, height: -1))
            } else {
                Image(conveyor.currentFrame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: conveyor.frameSize.width, height: conveyor.frameSize.height)
                    .background(.clear)
                
            }
        }.background(.clear)
            .frame(width: 1,height: 1,alignment: .center)
    }
}
