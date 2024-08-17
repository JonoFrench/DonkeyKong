//
//  HowHighView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 16.08.24.
//

import SwiftUI

struct HowHighView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("25 m")
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: 12))
                Spacer()
                ImageView(image: ImageResource(name: "KongHowHigh", bundle: .main), frameSize: CGSize(width: 96, height: 96))
                Spacer()
            }
            Text("How high can you get ?")
                .foregroundStyle(.white)
                .font(.custom("DonkeyKongClassicsNESExtended", size: 12))
        }.background(.black)
    }
}

#Preview {
    HowHighView()
}
