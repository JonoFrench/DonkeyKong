//
//  HowHighView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 16.08.24.
//

import SwiftUI

struct HowHighView: View {
#if os(iOS)
    static var textSize:CGFloat = 12
#elseif os(tvOS)
    static var textSize:CGFloat = 24
#endif

    var level:Int
    var body: some View {
        VStack {
            Spacer()
            if level >= 4 {
                HowHighLineView(howHigh: "100 m")
            }
            if level >= 3 {
                HowHighLineView(howHigh: "75 m")
            }
            if level >= 2 {
                HowHighLineView(howHigh: "50 m")
            }
            if level >= 1 {
                HowHighLineView(howHigh: "25 m")
            }
            Text("How high can you get ?")
                .foregroundStyle(.white)
                .font(.custom("DonkeyKongClassicsNESExtended", size: HowHighView.textSize))
        }.background(.black)
    }
}

#Preview {
    HowHighView(level: 4)
}
