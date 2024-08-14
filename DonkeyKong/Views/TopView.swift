//
//  TopView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import SwiftUI

struct TopView: View {
    @EnvironmentObject var manager: GameManager
    var body: some View {
        VStack {
            HStack {
                //Spacer()
                VStack {
                    Text("1UP")
                        .foregroundStyle(.red)
                        .font(.custom("DonkeyKongClassicsNESExtended", size: 14))
                        .padding([.leading])
                    //Spacer()
                    Text("\(String(format: "%06d", manager.score))")
                        .foregroundStyle(.white)
                        .font(.custom("DonkeyKongClassicsNESExtended", size: 14))
                        .padding([.leading])
                }
                Spacer()
                VStack {
                    Text("HIGH SCORE")
                        .foregroundStyle(.red)
                        .font(.custom("DonkeyKongClassicsNESExtended", size: 14))
                        .padding([.trailing])
                    //Spacer()
                    Text("\(String(format: "%06d", manager.highScore))")
                        .foregroundStyle(.white)
                        .font(.custom("DonkeyKongClassicsNESExtended", size: 14))
                        .padding([.trailing])

                    
                }
            }
            HStack {
                Text("HH")
                HStack(alignment:.firstTextBaseline ,content:
                        {
                    ForEach(0..<manager.lives, id: \.self) {_ in
                        ImageView(image: ImageResource(name: "Lives", bundle: .main),frameSize: CGSize(width: 16, height: 16))
                    }
                })
                Spacer()
            }
        }.background(.introBackground)
    }
}

#Preview {
    let previewEnvObject = GameManager()
    return TopView()
        .environmentObject(previewEnvObject)
    
}
