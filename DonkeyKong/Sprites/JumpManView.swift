//
//  ImageView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 12.08.24.
//

import SwiftUI

struct JumpManView: View {
    //var jumpMan:JumpMan?
    @ObservedObject var jumpMan:JumpMan
    var body: some View {
        //if let jumpMan = jumpMan {
            ZStack {
                if jumpMan.facing == .right {
                Image(jumpMan.currentFrame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: jumpMan.frameSize.width, height: jumpMan.frameSize.height)
                    .rotationEffect(Angle(degrees: 180))
                    .background(.clear)
                    .scaleEffect(CGSize(width: 1, height: -1))
                } else {
                    Image(jumpMan.currentFrame)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: jumpMan.frameSize.width, height: jumpMan.frameSize.height)
                        //.rotationEffect(Angle(degrees: 180))
                        .background(.clear)
            }
            }.background(.clear)
       // }
    }
}

//#Preview {
//    JumpManView(image: ImageResource(name: "JM1", bundle: .main),frameSize: CGSize(width: 13.1, height: 13.1))
//}

