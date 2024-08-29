//
//  StartView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var manager: GameManager
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Image("Title")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Spacer()
                Text("Jonathan French 2024")
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: 14))
                Spacer()
                Text("(C) 1981 Nintendo")
                    .foregroundStyle(.white)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: 12))
                Spacer()
                Text("Press Jump to Start")
                    .foregroundStyle(.red)
                    .font(.custom("DonkeyKongClassicsNESExtended", size: 14))
                //Spacer()
            }
                .onAppear {
                    print("game size \(proxy.size)")
                    manager.gameScreen.gameSize = proxy.size
                }
        }.background(.introBackground)
    }
}

#Preview {
    let previewEnvObject = GameManager()
    return StartView()
        .environmentObject(previewEnvObject)
    
}
