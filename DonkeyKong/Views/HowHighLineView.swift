//
//  HowHighLineView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 23.08.24.
//

import SwiftUI

struct HowHighLineView: View {
#if os(iOS)
    static var textSize:CGFloat = 12
    static var kongSize = CGSize(width: 96, height: 96)
#elseif os(tvOS)
    static var textSize:CGFloat = 24
    static var kongSize = CGSize(width: 192, height: 192)
#endif

    var howHigh:String
    var body: some View {
        HStack {
            Spacer()
            Text("\(howHigh)")
                .foregroundStyle(.white)
                .font(.custom("DonkeyKongClassicsNESExtended", size: HowHighView.textSize))
            Spacer()
            ImageView(image: ImageResource(name: "KongHowHigh", bundle: .main), frameSize: HowHighLineView.kongSize)
            Spacer()
        }
    }
}

#Preview {
    HowHighLineView(howHigh: "25 m")
}
