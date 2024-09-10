//
//  StartView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import SwiftUI

struct StartView: View {
#if os(iOS)
    static var starttextSize:CGFloat = 14
    static var copyTextSize:CGFloat = 12
#elseif os(tvOS)
    static var starttextSize:CGFloat = 24
    static var copyTextSize:CGFloat = 28
#endif

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Image("Title")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Spacer()
                Text("Jonathan French 2024")
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: StartView.starttextSize))
                Spacer()
                Text("(C) 1981 Nintendo")
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: StartView.copyTextSize))
                Spacer()
                Text(AppConstant.startText)
                    .foregroundStyle(.red)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: StartView.starttextSize))
                //Spacer()
            }
        }.background(.black)
    }
}

#Preview {
    let previewEnvObject = GameManager()
    return StartView()
        .environmentObject(previewEnvObject)
    
}
