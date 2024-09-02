//
//  SpringView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 1.09.24.
//

import SwiftUI

struct SpringView: View {
    @ObservedObject var spring:Spring
    var body: some View {
        ZStack {
            Image(spring.currentFrame)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: spring.frameSize.width, height: spring.frameSize.height)
                .background(.clear)
                .zIndex(2.1)
        }.background(.clear)
            .frame(width: 1,height: 1,alignment: .center)
    }
}
