//
//  PaulineView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 17.08.24.
//

import SwiftUI

struct PaulineView: View {
    //@EnvironmentObject var manager: GameManager
    @ObservedObject var pauline:Pauline
    var body: some View {
//        if let pauline = manager.pauline {
            ZStack {
                //if let pauline = pauline {
                    if pauline.isShowing {
                        Image(pauline.currentFrame)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: pauline.frameSize.width, height: pauline.frameSize.height)
                            .background(.clear)
                    }
              //  }
            }.background(.clear)
                .frame(width: 1,height: 1,alignment: .center)
        }
//    }
}

//#Preview {
//    PaulineView()
//}
