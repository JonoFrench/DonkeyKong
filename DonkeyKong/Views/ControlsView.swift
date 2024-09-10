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
                    JoyPadView2()
                }
                Spacer()
                VStack {
                }
                
                Spacer()
                Image("ControlJump")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .onLongPressGesture(minimumDuration: 0.1){
                        if manager.gameState == .intro {
                            manager.startGame()
                        } else if manager.gameState == .playing {
                            if manager.jumpMan.canJump() {
                                if manager.jumpMan.isWalking  {
                                    manager.jumpMan.isWalking = false
                                    manager.jumpMan.isJumping = true
                                } else {
                                    manager.jumpMan.isJumpingUp = true
                                }
                            }
                        }
                    }
//                    .simultaneousGesture(TapGesture()
//                        .onEnded({
//                            if manager.gameState == .intro {
//                                manager.startGame()
//                            } else if manager.gameState == .playing {
//                                if manager.jumpMan.canJump() {
//                                    if manager.jumpMan.isWalking  {
//                                        manager.jumpMan.isWalking = false
//                                        manager.jumpMan.isJumping = true
//                                    } else {
//                                        manager.jumpMan.isJumpingUp = true
//                                    }
//                                }
//                            }
//                            
//                        })
//                    )
                Spacer()
            }
            
            Image("ControlBottom")
                .resizable()
                .scaledToFill()
                .aspectRatio(contentMode: .fill)
                .frame(width: manager.gameScreen.gameSize.width, height: 30)
        }
    }
}

#Preview {
    let previewEnvObject = GameManager()
    return ControlsView()
        .environmentObject(previewEnvObject)
    
}

