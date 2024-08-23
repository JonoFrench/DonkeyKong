//
//  HowHighLineView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 23.08.24.
//

import SwiftUI

struct HowHighLineView: View {
    var howHigh:String
    var body: some View {
        HStack {
            Spacer()
            Text("\(howHigh)")
                .foregroundStyle(.white)
                .font(.custom("DonkeyKongClassicsNESExtended", size: 12))
            Spacer()
            ImageView(image: ImageResource(name: "KongHowHigh", bundle: .main), frameSize: CGSize(width: 96, height: 96))
            Spacer()
        }
    }
}

#Preview {
    HowHighLineView(howHigh: "25 m")
}
