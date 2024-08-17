//
//  KongView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 16.08.24.
//

import SwiftUI

struct KongView: View {
    var kong:Kong?
    var body: some View {
        if let kong = kong {
            ZStack {
                if kong.state == .intro || kong.state == .jumpingup || kong.state == .bouncing || kong.state == .sitting {
                    Image(kong.currentFrame)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: kong.frameSize.width, height: kong.frameSize.height)
                    //                    .rotationEffect(Angle(degrees: 180))
                        .background(.clear)
                    //                    .scaleEffect(CGSize(width: 1, height: -1))
                }
                
            }.background(.clear)
                .frame(width: 1,height: 1,alignment: .center)
        }
    }
}

#Preview {
    KongView()
}


//.offset(x: animated ? 200 : 0)
//        .animation(.easeInOut, value: animated) // The scope of the animation modifier is the current view hierarchy and its subviews
