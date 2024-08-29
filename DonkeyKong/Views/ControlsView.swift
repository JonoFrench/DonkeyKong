//
//  ControlsView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var manager: GameManager
    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    JoyPadView()
                }
                Spacer()
                VStack {
                    //Spacer()
//                    Image("MiddleDK")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .alignmentGuide(.bottom) { d in d[.bottom] - 42 }
//                        .frame(width: 80, height: 80,alignment: .bottom)
                }
                
                Spacer()
                
                Button(action: {
                    // Jump action
                    if manager.gameState == .intro {
                        manager.startGame()
                    } else if manager.gameState == .playing {
                        if manager.jumpMan.canJump() {
                            if manager.jumpMan.isWalkingLeft || manager.jumpMan.isWalkingRight {
                                print("Jump activated")
                                manager.jumpMan.willJump = true
                            } else {
                                print("Jump Now")
                                manager.jumpMan.isJumpingUp = true
                            }
                        }
                    }
                }) {
                    Image("ControlJump")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                }
                Spacer()
                
            }//.background(.controlBackground)
                
            Image("ControlBottom")
                .resizable()
                .scaledToFill()
                .aspectRatio(contentMode: .fill)
                .frame(width: manager.gameScreen.gameSize.width, height: 30)
            
        }//.background(.controlBackground)
    }
}

#Preview {
    let previewEnvObject = GameManager()
    return ControlsView()
        .environmentObject(previewEnvObject)
    
}

