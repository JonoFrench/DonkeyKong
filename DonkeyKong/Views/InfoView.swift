//
//  InfoView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import SwiftUI

struct InfoView: View {
#if os(iOS)
    static var starttextSize:CGFloat = 14
#elseif os(tvOS)
    static var starttextSize:CGFloat = 28
#endif
    var body: some View {
        VStack {
//            Spacer()
            Image("Instructions")
                .resizable()
                .aspectRatio(contentMode: .fit)
//                .frame(width: 50, height: 50)
//                .rotationEffect(.degrees(90))
            Spacer()
            Text(AppConstant.startText)
                .foregroundStyle(.red)
                .font(.custom("DonkeyKongClassicsNESExtended", size: InfoView.starttextSize))
//            Spacer()
        }.background(.black)
    }
}
#Preview {
    InfoView()
}
