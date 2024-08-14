//
//  InfoView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        VStack {
//            Spacer()
            Image("Instructions")
                .resizable()
                .aspectRatio(contentMode: .fit)
//                .frame(width: 50, height: 50)
//                .rotationEffect(.degrees(90))
            Spacer()
            Text("Press Jump to Start")
                .foregroundStyle(.red)
                .font(.custom("DonkeyKongClassicsNESExtended", size: 14))
//            Spacer()
        }.background(.introBackground)
    }
}
#Preview {
    InfoView()
}
