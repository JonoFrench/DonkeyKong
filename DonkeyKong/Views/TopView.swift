//
//  TopView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import SwiftUI

struct TopView: View {
    @EnvironmentObject var manager: GameManager
#if os(iOS)
    static var topTextSize:CGFloat = 14
    static var copyTextSize:CGFloat = 12
    static var liveSize = CGSize(width: 16, height: 16)
#elseif os(tvOS)
    static var topTextSize:CGFloat = 28
    static var copyTextSize:CGFloat = 28
    static var liveSize = CGSize(width: 32, height: 32)
#endif

    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("1UP")
                        .foregroundStyle(.red)
                        .font(.custom("DonkeyKongClassicsNESExtended", size: TopView.topTextSize))
                        .padding([.leading])
                    Text("\(String(format: "%06d", manager.score))")
                        .foregroundStyle(.white)
                        .font(.custom("DonkeyKongClassicsNESExtended", size: TopView.topTextSize))
                        .padding([.leading])
                }
                Spacer()
                VStack {
                    Text("HIGH SCORE")
                        .foregroundStyle(.red)
                        .font(.custom("DonkeyKongClassicsNESExtended", size: TopView.topTextSize))
                        .padding([.trailing])
                    Text("\(String(format: "%06d", manager.hiScores.highScore))")
                        .foregroundStyle(.white)
                        .font(.custom("DonkeyKongClassicsNESExtended", size: TopView.topTextSize))
                        .padding([.trailing])
                }
            }
            HStack {
                HStack(alignment:.firstTextBaseline ,content:
                        {
                    ForEach(0..<manager.lives, id: \.self) {_ in
                        ImageView(image: ImageResource(name: "Lives", bundle: .main),frameSize: TopView.liveSize)
                    }
                })
                Spacer()
            }
        }.background(.black)
    }
}

#Preview {
    let previewEnvObject = GameManager()
    return TopView()
        .environmentObject(previewEnvObject)
    
}
