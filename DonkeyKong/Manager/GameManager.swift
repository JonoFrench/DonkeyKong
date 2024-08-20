//
//  GameManager.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import Foundation
import QuartzCore
import SwiftUI

enum GameState {
    case intro,kongintro,howhigh,playing,ended,highscore
}

class GameManager: ObservableObject {
    let soundFX:SoundFX = SoundFX()
    
    let screenDimentionX = 30
    let screenDimentionY = 28
    var assetDimention = 0.0
    var assetOffset = 0.0
    var verticalOffset = 0.0
    var currentHeightOffset = 0.0
    let hiScores:DonkeyKongHighScores = DonkeyKongHighScores()
    var gameSize = CGSize()
    var screenSize = CGSize()
    @Published
    var gameState:GameState = .intro
    @Published
    var lives = 3
    var score = 0
    var highScore = 9999
    var level = 1
    @Published
    var bonus = 5000
    ///New High Score Handling
    @Published
    var letterIndex = 0
    @Published
    var letterArray:[Character] = ["A","A","A"]
    @Published
    var selectedLetter = 0
    
    @Published
    var screenData:[[ScreenAsset]] = [[]]
    ///Sprites of sorts....
    @ObservedObject
    var jumpMan:JumpMan = JumpMan()
    var isWalking = false
    var isWalkingRight = false
    var isWalkingLeft = false
    var isClimbing = false
    var isClimbingUp = false
    var isClimbingDown = false
    var ladderHeight = 0.0
    var ladderStep = 0.0
    var startedClimbing = false
    
    var jmAnimationCounter = 0
    
    @Published
    var kongIntroCounter = 0
    @ObservedObject var kong:Kong = Kong()
    var dkAnimationCounter = 0
    var dkBouncePos = 0
    var dkBounceYPos = 0
    @ObservedObject var pauline:Pauline = Pauline()
    let heartBeat = 0.6
    @ObservedObject var flames:Flames = Flames()
    var collectibles:[Collectible] = []
    
    init() {
        ///Here we go, lets have a nice DisplayLink to update our model with the screen refresh.
        let displayLink:CADisplayLink = CADisplayLink(target: self, selector: #selector(refreshModel))
        displayLink.add(to: .main, forMode:.common)
    }
    
    @objc func refreshModel() {
        if gameState == .kongintro {
            if kong.state == .intro {
                animateIntro()
            } else if kong.state == .jumpingup {
                animateJumpUp()
            } else if kong.state == .bouncing {
                animateHop()
            }
        }
        
        if gameState == .playing {
            moveJumpMan()
            animateJumpMan()
            pauline.animate()
            flames.animate()
        }
    }
    
    func startGame() {
        assetDimention = gameSize.width / Double(screenDimentionX - 1)
        assetOffset = assetDimention / 8.0
        verticalOffset =  -50.0 //(gameSize.height - (assetDimention * 25.0))
        print("assetDimention \(assetDimention)")
        print("assetOffset \(assetOffset)")
        print("verticalOffset \(verticalOffset)")
        setKongIntro()
        //startPlaying()
    }
    
    func startPlaying() {
        setDataForLevel()
        gameState = .playing
        startBonusCountdown()
        //startHeartBeat()
        whatsAround()
    }
    
    func setDataForLevel() {
        screenData = Screens().getScreenData()
        jumpMan.xPos = 2
        jumpMan.yPos = 27
        //jumpMan.hasHammer = true
        jumpMan.jumpManPosition = calcPositionFromScreen(xPos: jumpMan.xPos,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
        
        pauline.xPos = 14
        pauline.yPos = 3
        pauline.paulinePosition = calcPositionFromScreen(xPos: pauline.xPos,yPos: pauline.yPos,frameSize: pauline.frameSize)
        kong.xPos = 6
        kong.yPos = 7
        kong.kongPosition = calcPositionFromScreen(xPos: kong.xPos,yPos: kong.yPos,frameSize: kong.frameSize)
        kong.kongPosition.y += 7
        pauline.isShowing = true
        flames.flamesPosition = calcPositionFromScreen(xPos: flames.xPos,yPos: flames.yPos,frameSize: flames.frameSize)
        flames.flamesPosition.y += 4
        flames.flamesPosition.x -= 8
        
        let collectible1 = Collectible(type: .hammer, xPos: 3, yPos: 10)
        collectible1.collectiblePosition = calcPositionFromScreen(xPos: collectible1.xPos,yPos: collectible1.yPos,frameSize: collectible1.frameSize)
        let collectible2 = Collectible(type: .hammer, xPos: 20, yPos: 21)
        collectible2.collectiblePosition = calcPositionFromScreen(xPos: collectible2.xPos,yPos: collectible2.yPos,frameSize: collectible2.frameSize)
        collectibles.append(collectible1)
        collectibles.append(collectible2)
    }
    
    func startBonusCountdown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            bonus -= 100
            if bonus > 0 {
                startBonusCountdown()
            }
        }
    }
    
    /// Sound FX of the game
    func startHeartBeat(){
        if gameState == .playing {
            DispatchQueue.main.asyncAfter(deadline: .now() + heartBeat) { [self] in
                soundFX.backgroundSound()
                DispatchQueue.main.asyncAfter(deadline: .now() + heartBeat) { [self] in
                    soundFX.backgroundSound()
                    startHeartBeat()
                }
            }
        }
    }
    
    func moveJumpMan() {
        if !isWalking {
            if isWalkingRight {
                print("walk right")
                walkRight()
            } else if isWalkingLeft {
                print("walk left")
                walkLeft()
            }
        }
        if !isClimbing {
            if isClimbingUp {
                print("climb up")
                climbUp()
            } else if isClimbingDown {
                print("climb down")
                climbDown()
            }
        }
    }
    
    func animateJumpMan(){
        guard isWalking || isClimbing else {
            return
        }
        if jmAnimationCounter == jumpMan.animationFrames {
            if isWalking {
                startedClimbing = false
                if jumpMan.facing == .right {
                    animateJMRight()
                } else {
                    animateJMLeft()
                }
            } else if isClimbing {
                if isClimbingUp {
                    if !startedClimbing {
                        startedClimbing = true
                    }
                    animateJMUp()
                } else {
                    if !startedClimbing {
                        startedClimbing = true
                    }
                    animateJMDown()
                }
            }
            jmAnimationCounter = 0
        }
        jmAnimationCounter += 1
    }
    
    func walkRight() {
        guard canMoveRight() else {
            isWalking = false
            isWalkingRight = false
            return
        }
        isWalking = true
        jumpMan.facing = .right
        animateJMRight()
        currentHeightOffset = screenData[jumpMan.yPos][jumpMan.xPos].assetOffset
        if currentHeightOffset != screenData[jumpMan.yPos][jumpMan.xPos+1].assetOffset {
            if currentHeightOffset > screenData[jumpMan.yPos][jumpMan.xPos+1].assetOffset {
                jumpMan.jumpManPosition.y += self.assetOffset
            } else {
                jumpMan.jumpManPosition.y -= self.assetOffset
            }
        }
    }
    
    func walkLeft() {
        guard canMoveLeft() else {
            isWalking = false
            isWalkingLeft = false
            return
        }
        isWalking = true
        jumpMan.facing = .left
        animateJMLeft()
        currentHeightOffset = screenData[jumpMan.yPos][jumpMan.xPos].assetOffset
        if currentHeightOffset != screenData[jumpMan.yPos][jumpMan.xPos-1].assetOffset {
            if currentHeightOffset > screenData[jumpMan.yPos][jumpMan.xPos-1].assetOffset {
                jumpMan.jumpManPosition.y += self.assetOffset
            } else {
                jumpMan.jumpManPosition.y -= self.assetOffset
            }
        }
    }
    
    func animateJMRight(){
        print("walking right frame \(jumpMan.animateFrame)")
        jumpMan.jumpManPosition.x += assetDimention / 3.0
        if jumpMan.hasHammer {
            jumpMan.currentFrame = jumpMan.hammerFrame == false ? jumpMan.hammer1[jumpMan.animateFrame] : jumpMan.hammer2[jumpMan.animateFrame]
        } else {
            jumpMan.currentFrame = jumpMan.walking[jumpMan.animateFrame]
        }
        jumpMan.animateFrame += 1
        if jumpMan.animateFrame == 3 {
            jumpMan.animateFrame = 0
            isWalking = false
            jumpMan.hammerFrame = !jumpMan.hammerFrame
            if jumpMan.xPos < screenDimentionX {
                jumpMan.xPos += 1
            }
            whatsAround()
        }
    }
    
    func animateJMLeft(){
        jumpMan.jumpManPosition.x -= assetDimention / 3.0
        if jumpMan.hasHammer {
            jumpMan.currentFrame = jumpMan.hammerFrame == false ? jumpMan.hammer1[jumpMan.animateFrame] : jumpMan.hammer2[jumpMan.animateFrame]
        } else {
            jumpMan.currentFrame = jumpMan.walking[jumpMan.animateFrame]
        }
        jumpMan.animateFrame += 1
        if jumpMan.animateFrame == 3 {
            jumpMan.animateFrame = 0
            isWalking = false
            jumpMan.hammerFrame = !jumpMan.hammerFrame
            if jumpMan.xPos > 0 {
                jumpMan.xPos -= 1
            }
            whatsAround()
        }
    }
    
    func animateJMUp(){
        jumpMan.jumpManPosition.y -= ladderStep / 4.0
        jumpMan.currentFrame = jumpMan.climbing[jumpMan.animateFrame]
        jumpMan.animateFrame += 1
        if jumpMan.facing == .left {
            jumpMan.facing = .right
        } else {
            jumpMan.facing = .left
        }
        if jumpMan.animateFrame == 4 {
            jumpMan.animateFrame = 0
            isClimbing = false
            isClimbingUp = false
            if jumpMan.yPos != 0 {
                jumpMan.yPos -= 1
                currentHeightOffset = screenData[jumpMan.yPos][jumpMan.xPos].assetOffset
            }
            if !isLadderAbove() {
                jumpMan.currentFrame = ImageResource(name: "JMBack", bundle: .main)
                isClimbing = false
                isClimbingUp = false
            }
            whatsAround()
        }
    }
    
    func animateJMDown() {
        jumpMan.jumpManPosition.y += ladderStep / 4.0
        jumpMan.currentFrame = jumpMan.climbing[jumpMan.animateFrame]
        jumpMan.animateFrame += 1
        if jumpMan.facing == .left {
            jumpMan.facing = .right
        } else {
            jumpMan.facing = .left
        }
        if jumpMan.animateFrame == 4 {
            jumpMan.animateFrame = 0
            isClimbing = false
            isClimbingDown = false
            if jumpMan.yPos < screenDimentionY - 1 {
                jumpMan.yPos += 1
                currentHeightOffset = screenData[jumpMan.yPos][jumpMan.xPos].assetOffset
            }
            if !isLadderBelow() {
                jumpMan.currentFrame = ImageResource(name: "JMBack", bundle: .main)
                isClimbing = false
                isClimbingDown = false
            }
            whatsAround()
        }
    }
    
    func calculateLadderHeightUp() {
        jumpMan.animateFrame = 0
        var yCount = 0
        while screenData[jumpMan.yPos-(yCount+1)][jumpMan.xPos].assetType == .ladder || jumpMan.yPos-yCount == 0 {
            yCount += 1
        }
        let endPosition = calcPositionFromScreen(xPos: jumpMan.xPos,yPos: jumpMan.yPos - (yCount + 1),frameSize: jumpMan.frameSize)
        ladderHeight = jumpMan.jumpManPosition.y - endPosition.y
        ladderStep = ladderHeight / Double(yCount + 1)
    }
    
    func calculateLadderHeightDown() {
        jumpMan.animateFrame = 0
        var yCount = 0
        while screenData[jumpMan.yPos+yCount+1][jumpMan.xPos].assetType == .ladder {
            yCount += 1
        }
        let endPosition = calcPositionFromScreen(xPos: jumpMan.xPos, yPos: jumpMan.yPos+(yCount+1),frameSize: jumpMan.frameSize)
        ladderHeight = endPosition.y - jumpMan.jumpManPosition.y
        ladderStep = ladderHeight / Double(yCount+1)
    }
    
    func calcPositionForAsset(xPos:Int, yPos:Int) -> CGPoint  {
        let assetOffsetAtPosition = screenData[yPos][xPos].assetOffset
        return CGPoint(x: Double(xPos) * assetDimention + (assetDimention / 2), y: Double(yPos) * assetDimention - (assetOffset * assetOffsetAtPosition) + 80)
    }
    
    func calcPositionFromScreen(xPos:Int,yPos:Int,frameSize:CGSize) -> CGPoint {
        var position = calcPositionForAsset(xPos: xPos, yPos: yPos)
        position.y -= (frameSize.height / 2) + (assetDimention / 2)
        return position
    }
    
    func climbUp() {
        isClimbing = true
        animateJMUp()
    }
    
    func climbDown() {
        isClimbing = true
        animateJMDown()
    }
    
    func isBlankAbove() -> Bool {
        if screenData[jumpMan.yPos - 1][jumpMan.xPos].assetType == .blank {
            return true
        }
        return false
    }
    
    func isLadderAbove() -> Bool {
        if screenData[jumpMan.yPos - 1][jumpMan.xPos].assetType == .blank { return false }
        if screenData[jumpMan.yPos - 1][jumpMan.xPos].assetType == .ladder || screenData[jumpMan.yPos][jumpMan.xPos].assetType == .ladder {
            return true
        }
        return false
    }
    
    func isLadderBelow() -> Bool {
        if screenData[jumpMan.yPos][jumpMan.xPos].assetType == .ladder { return true }
        if screenData[jumpMan.yPos][jumpMan.xPos].assetType == .blank { return false }
        if jumpMan.yPos <= screenDimentionY - 2 {
            if screenData[jumpMan.yPos + 1][jumpMan.xPos].assetType == .ladder || screenData[jumpMan.yPos + 1][jumpMan.xPos].assetType == .girder {
                return true
            } else {
                if screenData[jumpMan.yPos + 1][jumpMan.xPos].assetType == .girder {
                    return true
                }
            }
        }
        return false
    }
    
    func canMoveLeft() -> Bool {
        guard jumpMan.xPos > 0 else {
            return false
        }
        if screenData[jumpMan.yPos][jumpMan.xPos - 1].assetType != .blank {
            return true
        }
        return false
    }
    
    func canMoveRight() -> Bool {
        guard jumpMan.xPos < screenDimentionX - 2 else {
            return false
        }
        if screenData[jumpMan.yPos][jumpMan.xPos + 1].assetType != .blank {
            return true
        }
        return false
    }
    
    func canClimbLadder() -> Bool {
        guard isLadderAbove() && !isClimbing else {
            return false
        }
        return true
    }
    
    func canDecendLadder() -> Bool {
        guard isLadderBelow() && !isClimbing else {
            return false
        }
        return true
    }
    
    func canStandFromLadder() -> Bool {
        guard isClimbing else {
            return false
        }
        if isClimbingUp {
            if screenData[jumpMan.yPos - 1][jumpMan.xPos].assetType == .girder {
                return true
            }
        } else if isClimbingDown {
            if screenData[jumpMan.yPos + 1][jumpMan.xPos].assetType == .girder {
                return true
            }
        }
        return false
    }
    
    func whatsAround() {
        //return
        print("JumpMan Current position is X \(jumpMan.xPos) Y \(jumpMan.yPos)")
        print("JumpMan Current screen position is \(jumpMan.jumpManPosition)")
        print("JumpMan Current height offset is \(currentHeightOffset)")
        print("Current Standing on is \(screenData[jumpMan.yPos][jumpMan.xPos].assetType)")
        if jumpMan.xPos == 0 {
            print("Nothing Behind")
        } else {
            print("Behind is \(screenData[jumpMan.yPos-1][jumpMan.xPos - 1].assetType)")
        }
        if jumpMan.xPos > screenDimentionX {
            print("Nothing In front")
        } else {
            print("In front is \(screenData[jumpMan.yPos-1][jumpMan.xPos + 1].assetType)")
        }
        if jumpMan.yPos == 0 {
            print("Nothing above")
        } else {
            print("Above is \(screenData[jumpMan.yPos - 1][jumpMan.xPos].assetType)")
        }
        if jumpMan.yPos == 27 {
            print("Nothing Below")
        } else {
            print("Below is \(screenData[jumpMan.yPos + 1][jumpMan.xPos].assetType)")
        }
    }
    
}
