//
//  GameManager+KongIntro.swift
//  DonkeyKong
//
//  Created by Jonathan French on 16.08.24.
//

import Foundation

extension GameManager {
    
    func setKongIntro() {
        gameState = .kongintro
        gameScreen.screenData = KongScreen().getScreenData()
        kong.setPosition(xPos: 16, yPos: 25)
        kong.adjustPosition()
        gameScreen.setLadders()
        pauline.setPosition(xPos: 14, yPos: 3)
        pauline.isShowing = false
        runKongIntro()
    }
    
    func runKongIntro() {
        soundFX.introLongSound()
        kong.state = .intro
        kong.introCounter = 27
        gameScreen.clearLadder(line: kong.introCounter)
    }
    
}
