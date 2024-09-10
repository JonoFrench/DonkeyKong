//
//  GameManager+TV.swift
//  DonkeyKong
//
//  Created by Jonathan French on 7.09.24.
//

import Foundation
#if os(tvOS)
import GameController
#endif

extension GameManager {
    
#if os(tvOS)

    func setupController(_ controller: GCController) {
        if let gamepad = controller.extendedGamepad {
            // Respond to button presses and axis movements
            gamepad.buttonA.pressedChangedHandler = { [self] (button, value, pressed) in
                if pressed {
                    DispatchQueue.main.async { [self] in
                    print("Button A pressed")
                        if gameState == .intro {
                        startGame()
                    } else {
                        if jumpMan.canJump() {
                            if jumpMan.isWalking  {
                                jumpMan.isWalking = false
                                jumpMan.isJumping = true
                            } else {
                                jumpMan.isJumpingUp = true
                            }
                        }
                    }
                    }
                }
            }

            gamepad.dpad.valueChangedHandler = {[unowned self] _, xValue, yValue in
//                print("Dpad moved: x = \(xValue), y = \(yValue)")
                DispatchQueue.main.async { [self] in
                    if xValue == -0.0 && yValue == 0.0 {
                        self.moveDirection = .stop
                    } else
                    if xValue < 0.0 {
                        self.moveDirection = .left
                    } else
                    if xValue > 0.0 {
                        self.moveDirection = .right
                    } else
                    if yValue < 0.0 {
                        self.moveDirection = .down
                    } else
                    if yValue > 0.0 {
                        self.moveDirection = .up
                    }
                }

            }
            
            gamepad.leftThumbstick.valueChangedHandler = { (dpad, xValue, yValue) in
//                print("Left thumbstick moved: x = \(xValue), y = \(yValue)")
                if xValue == -0.0 && yValue == 0.0 {
                    self.moveDirection = .stop
                } else
                if xValue < 0.0 {
                    self.moveDirection = .left
                } else
                if xValue > 0.0 {
                    self.moveDirection = .right
                } else
                if yValue < 0.0 {
                    self.moveDirection = .down
                } else
                if yValue > 0.0 {
                    self.moveDirection = .up
                }

                
            }
        }
    }

    
    
#endif

}
