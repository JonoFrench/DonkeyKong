//
//  BonusBoxView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 12.08.24.
//

import SwiftUI

struct BonusBoxView: View {
    @EnvironmentObject var manager: GameManager
    var body: some View {
        ZStack {
            VStack {
                //Spacer()
                Text("L=\(String(format: "%02d", manager.level))")
                    .foregroundStyle(.blue)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: 14))
                    .frame(maxWidth: 100, alignment: .leading)
                    //.padding([.trailing]
                    Image("BonusBox")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 60,alignment: .bottom)
                        .overlay(alignment: .bottom, content: {

                            Text("\(String(format: "%04d", manager.bonus))")
                                .foregroundStyle(.cyan)
                                .font(.custom("DonkeyKongClassicsNESExtended", size: 12))
                                .padding(.bottom, 6)
                        })
                    //Spacer()
            }
        }.background(.black)
    }
}

#Preview {
    let previewEnvObject = GameManager()
    return BonusBoxView()
        .environmentObject(previewEnvObject)
}
