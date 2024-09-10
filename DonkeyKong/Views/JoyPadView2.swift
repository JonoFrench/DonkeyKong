//
//  JoyPadView2.swift
//  DonkeyKong
//
//  Created by Jonathan French on 29.08.24.
//

import SwiftUI

struct JoyPadView2: View {
    @EnvironmentObject var manager: GameManager
    @GestureState private var _isPressingDown: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                Image("ControlDirection")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(90))
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.1)
                        .sequenced(before: LongPressGesture(minimumDuration: .infinity))
                        .updating($_isPressingDown) { value, state, transaction in
                            switch value {
                            case .second(true, nil): //This means the first Gesture completed
                                state = true
                                manager.moveDirection = .up
                            default: break
                            }
                        })
                    .onChange(of: _isPressingDown) {oldValue, value in
                        if !value {
                            manager.moveDirection = .stop
                        }
                    }
                Spacer()
            }
            
            HStack(spacing: 0) {
                Image("ControlDirection")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.1)
                        .sequenced(before: LongPressGesture(minimumDuration: .infinity))
                        .updating($_isPressingDown) { value, state, transaction in
                            switch value {
                            case .second(true, nil): //This means the first Gesture completed
                                state = true
                                manager.moveDirection = .left
                            default: break
                            }
                        })
                    .onChange(of: _isPressingDown) {oldValue, value in
                        if !value {
                            manager.moveDirection = .stop
                        }
                    }

                
                Spacer()
                if manager.gameState == .intro {
                    // Center Circle
                    Circle()
                        .fill(Color.black)
                        .frame(width: 30, height: 30)
                        .overlay(alignment: .center, content: {
                            Text("\(manager.gameScreen.level)")
                                .foregroundStyle(.white)
                                .font(.custom("DonkeyKongClassicsNESExtended", size: 8))
                            //.padding(.bottom, 6)
                        })
                        .onTapGesture(count: 2) {
                            print("Double tapped!")
                            manager.gameScreen.level += 1
                            manager.objectWillChange.send()
                        }
                } else {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 30, height: 30)
                        .onTapGesture(count: 3) {
                            print("Triple tapped!")
                            manager.gameState = .intro
                        }
                }
                Spacer()
                
                Image("ControlDirection")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(180))
                
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.1)
                        .sequenced(before: LongPressGesture(minimumDuration: .infinity))
                        .updating($_isPressingDown) { value, state, transaction in
                            switch value {
                            case .second(true, nil): //This means the first Gesture completed
                                state = true
                                manager.moveDirection = .right
                            default: break
                            }
                        })
                    .onChange(of: _isPressingDown) {oldValue, value in
                        if !value {
                            manager.moveDirection = .stop
                        }
                    }
            }
            
            HStack(spacing: 0) {
                Spacer()
                Image("ControlDirection") // Down action
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(270))
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.1)
                        .sequenced(before: LongPressGesture(minimumDuration: .infinity))
                        .updating($_isPressingDown) { value, state, transaction in
                            switch value {
                            case .second(true, nil): //This means the first Gesture completed
                                state = true
                                manager.moveDirection = .down
                            default: break
                            }
                        })
                    .onChange(of: _isPressingDown) {oldValue, value in
                        if !value {
                            manager.moveDirection = .stop
                        }
                    }
                Spacer()
            }
        }
        .frame(width: 180, height: 180)
    }
}

#Preview {
    JoyPadView2()
}

