//
//  PaulineView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 17.08.24.
//

import SwiftUI

struct PaulineView: View {
    var pauline:Pauline?
    var body: some View {
        if let pauline = pauline {
            ZStack {
                if pauline.isShowing {
                    Image(pauline.currentFrame)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: pauline.frameSize.width, height: pauline.frameSize.height)
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
    PaulineView()
}
