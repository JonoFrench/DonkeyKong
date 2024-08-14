//
//  ImageView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 12.08.24.
//

import SwiftUI

struct ImageView: View {
    var image:ImageResource?
    var frameSize: CGSize?
    var body: some View {
        ZStack {
            Image(image!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: frameSize?.width, height: frameSize?.height)
                .background(.clear)
        }.background(.clear)
    }
}

#Preview {
    ImageView(image: ImageResource(name: "Girder", bundle: .main),frameSize: CGSize(width: 13.1, height: 13.1))
}

