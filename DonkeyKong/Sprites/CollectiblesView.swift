//
//  CollectiblesView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 18.08.24.
//

import SwiftUI

struct CollectiblesView: View {
    @ObservedObject var collectible:Collectible
    var body: some View {
        ZStack {
            if !collectible.collected {
                Image(collectible.collectibleImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: collectible.frameSize.width, height: collectible.frameSize.height)
                    .background(.clear)
            }
        }.background(.clear)
            .frame(width: 1,height: 1,alignment: .center)
    }
}

