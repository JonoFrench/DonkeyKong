//
//  JoyPadView.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import SwiftUI

struct JoyPadView: View {
    @EnvironmentObject var manager: GameManager
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                Image("ControlDirection")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(90))
                    .gesture(
                        DragGesture(minimumDistance: 0) // Adjust duration as needed
                            .onChanged { _ in
                                if manager.gameState == .playing {
                                    if manager.canClimbLadder() {
                                        manager.calculateLadderHeightUp()
                                        manager.isClimbingUp = true
                                    }
                                }
                            }
                            .onEnded { _ in
                                if manager.gameState == .playing {
                                }
                            }
                    )
                Spacer()
            }
            
            HStack(spacing: 0) {
                Image("ControlDirection")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .gesture(
                        DragGesture(minimumDistance: 0) // Adjust duration as needed
                            .onChanged { _ in
                                if manager.gameState == .playing {
                                    if manager.canMoveLeft() {
                                        manager.isWalkingLeft = true
                                    }
                                }
                            }
                            .onEnded { _ in
                                if manager.gameState == .playing {
                                    manager.isWalkingLeft = false
                                }
                            }
                    )
                
                Spacer()
                
                // Center Circle
                Circle()
                    .fill(Color.black)
                    .frame(width: 30, height: 30)
                
                Spacer()
                
                Image("ControlDirection")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(180))
                    .gesture(
                        DragGesture(minimumDistance: 0)// Adjust duration as needed
                            .onChanged { _ in
                                if manager.gameState == .playing {
                                    if manager.canMoveRight() {
                                        manager.isWalkingRight = true
                                    }
                                }
                            }
                            .onEnded { _ in
                                if manager.gameState == .playing {
                                    manager.isWalkingRight = false
                                }
                            }
                    )
            }
            
            HStack(spacing: 0) {
                Spacer()
                Image("ControlDirection") // Down action
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(270))
                    .gesture(
                        DragGesture(minimumDistance: 0) // Adjust duration as needed
                            .onChanged { _ in
                                if manager.gameState == .playing {
                                    if manager.canDecendLadder() {
                                        manager.calculateLadderHeightDown()
                                        manager.isClimbingDown = true
                                    }
                                }
                            }
                            .onEnded { _ in
                                if manager.gameState == .playing {
                                }
                            }
                    )
                Spacer()
            }
        }
        .frame(width: 180, height: 180)
    }
}

#Preview {
    JoyPadView()
}
