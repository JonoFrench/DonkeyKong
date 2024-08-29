//
//  Kong.swift
//  DonkeyKong
//
//  Created by Jonathan French on 16.08.24.
//

import Foundation
import SwiftUI

enum KongState {
    case waiting,intro,jumpingup,bouncing,sitting,throwing,howhigh,dead
}

final class Kong:SwiftUISprite, ObservableObject {
    @Published
    var state:KongState = .waiting
    let kongClimbLeft:ImageResource = ImageResource(name: "KongClimbLeft", bundle: .main)
    let kongClimbRight:ImageResource = ImageResource(name: "KongClimbRight", bundle: .main)
    let kongFacing:ImageResource = ImageResource(name: "KongFacing", bundle: .main)
    let kongLeft:ImageResource = ImageResource(name: "KongThrowLeft", bundle: .main)
    let kongRight:ImageResource = ImageResource(name: "KongThrowRight", bundle: .main)
    let kongDown:ImageResource = ImageResource(name: "KongThrowDown", bundle: .main)
    var kongStep = false
    var jumpingPoints:[Int] = [11,10,9,8,7,8]
    var bouncingPoints = [[CGPoint]]()
    var animationCounter = 0
    var bouncePos = 0
    var bounceYPos = 0
    var isThrowing =  false
    @Published
    var introCounter = 0
    var showPauline = false
    
    override init(xPos: Int, yPos: Int, frameSize: CGSize) {
        super.init(xPos: xPos, yPos: yPos, frameSize: frameSize)
        currentFrame = ImageResource(name: "KongClimbRight", bundle: .main)
    }
    
    override func setPosition(xPos: Int, yPos: Int) {
        super.setPosition(xPos: xPos, yPos: yPos)
        position.y += 7
    }
    
    func runIntro() {
        if let resolvedInstance: SoundFX = ServiceLocator.shared.resolve() {
            resolvedInstance.introLongSound()
        }
        state = .intro
        introCounter = 27
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            resolvedInstance.clearLadder(line: introCounter)
        }
    }
    
    func adjustPosition() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            position.y += 9
            position.x += resolvedInstance.assetDimention / 2
        }
    }
    
    func nextStepUp() {
        kongStep = !kongStep
        if kongStep {
            currentFrame = kongClimbLeft
        } else {
            currentFrame = kongClimbRight
        }
        yPos -= 1
        position = calcPositionFromScreen()
        adjustPosition()
    }
    
    func animateExit() {
        animationCounter += 1
        if animationCounter == 14 {
            introCounter -= 1
            if introCounter > 0 {
                nextStepUp()
            } else {
                NotificationCenter.default.post(name: .notificationNextLevel, object: nil)
            }
            animationCounter = 0
        }
    }
    
    func exitLevel() {
        setPosition(xPos: 10, yPos: 7)
        introCounter = 8
        animationCounter = 0
        kongStep = false
        currentFrame = kongClimbLeft
        animateExit()
    }
    
    func animateIntro() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            animationCounter += 1
            if animationCounter == 14 {
                
                introCounter -= 1
                if introCounter > 10 {
                    resolvedInstance.clearLadder(line: introCounter)
                    nextStepUp()
                } else {
                    state = .jumpingup
                    introCounter = 0
                    
                }
                animationCounter = 0
            }
        }
    }
    
    func animateHop(){
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            animationCounter += 1
            if animationCounter == 4 {
                position = bouncingPoints[bouncePos][bounceYPos]
                adjustPosition()
                bounceYPos += 1
                if bounceYPos == bouncingPoints[bouncePos].count {
                    let line = 11 + (bouncePos * 4)
                    resolvedInstance.bendLine(line: line,assets: Screens().screen1[line])
                    bouncePos += 1
                    bounceYPos = 0
                }
                if bouncePos == 5 {
                    state = .sitting
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        NotificationCenter.default.post(name: .notificationHowHigh, object: nil)
                    }
                }
                animationCounter = 0
            }
        }
    }
    
    func animateJumpUp() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            animationCounter += 1
            if animationCounter == 4 {
                position = calcPositionFromScreen(xPos: xPos, yPos: jumpingPoints[introCounter],frameSize: frameSize)
                adjustPosition()
                introCounter += 1
                if introCounter > jumpingPoints.count - 1 {
                    yPos = 7
                    generateBouncingPoints()
                    showPauline = true
                    position = calcPositionFromScreen()
                    adjustPosition()
                    currentFrame = kongFacing
                    state = .sitting
                    resolvedInstance.bendLine(line: 7,assets: Screens().screen1[7])
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                        state = .bouncing
                    }
                }
                animationCounter = 0
            }
        }
    }
    
    func generateBouncingPoints() {
        var c = 0
        for i in stride(from: 16, through: 8, by: -2) {
            var pointA = calcPositionFromScreen(xPos: i, yPos: yPos,frameSize: frameSize)
            pointA.y -= 4.0
            var pointB = calcPositionFromScreen(xPos: i - 2, yPos: yPos,frameSize: frameSize)
            pointB.y -= 4.0
            let points = generateParabolicPoints(from: pointA, to: pointB, angleInDegrees: -50)
            bouncingPoints.append(points)
            c += 1
        }
    }
}
