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
    var ladderHeight = 0.0
    var ladderStep = 0.0
    
    var jmAnimationCounter = 0
    
    @Published
    var kongIntroCounter = 0
    @ObservedObject var kong:Kong = Kong()
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
                animateKongIntro()
            } else if kong.state == .jumpingup {
                animateKongJumpUp()
            } else if kong.state == .bouncing {
                animateKongHop()
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
        setKongIntro()   // If we don't want the intro....
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
        jumpMan.position = calcPositionFromScreen(xPos: jumpMan.xPos,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
        
        pauline.xPos = 14
        pauline.yPos = 3
        pauline.position = calcPositionFromScreen(xPos: pauline.xPos,yPos: pauline.yPos,frameSize: pauline.frameSize)
        kong.xPos = 6
        kong.yPos = 7
        kong.position = calcPositionFromScreen(xPos: kong.xPos,yPos: kong.yPos,frameSize: kong.frameSize)
        kong.position.y += 7
        pauline.isShowing = true
        flames.position = calcPositionFromScreen(xPos: flames.xPos,yPos: flames.yPos,frameSize: flames.frameSize)
        flames.position.y += 4
        flames.position.x -= 8
        
        let collectible1 = Collectible(type: .hammer, xPos: 3, yPos: 10)
        collectible1.position = calcPositionFromScreen(xPos: collectible1.xPos,yPos: collectible1.yPos,frameSize: collectible1.frameSize)
        let collectible2 = Collectible(type: .hammer, xPos: 20, yPos: 21)
        collectible2.position = calcPositionFromScreen(xPos: collectible2.xPos,yPos: collectible2.yPos,frameSize: collectible2.frameSize)
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
        if !jumpMan.isWalking && !jumpMan.isJumping {
            if jumpMan.isWalkingRight {
                print("walk right")
                walkRight()
            } else if jumpMan.isWalkingLeft {
                print("walk left")
                walkLeft()
            }
        }
        if !jumpMan.isClimbing {
            if jumpMan.isClimbingUp {
                print("climb up")
                climbUp()
            } else if jumpMan.isClimbingDown {
                print("climb down")
                climbDown()
            }
        }
        if !jumpMan.isJumping {
            if jumpMan.isJumpingUp {
                jump()
                print("Jump up")
            }
//            if jumpMan.isJumpingLeft {
//                jumpMan.isWalkingLeft = false
//                jump()
//                print("Jump Left")
//            }
//            if jumpMan.isJumpingRight {
//                jumpMan.isWalkingRight = false
//                jump()
//                print("Jump Right")
//            }
        }
    }
    
    func jump() {
        jumpMan.isJumping = true
        jumpMan.willJump = false
        jumpMan.isWalking = false
        let pointA = jumpMan.position
        var pointB = CGPoint()
        var points = [CGPoint]()
        if jumpMan.isJumpingLeft {
            pointB = calcPositionFromScreen(xPos: jumpMan.xPos - 2,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
//            pointB.y -= screenData[jumpMan.yPos][jumpMan.xPos - 2].assetOffset
            points = generateParabolicPoints(from: pointA, to: pointB,steps: 6, angleInDegrees: -60)
        } else {
            pointB = calcPositionFromScreen(xPos: jumpMan.xPos + 2,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
//            pointB.y -= screenData[jumpMan.yPos][jumpMan.xPos + 2].assetOffset
            points = generateParabolicPoints(from: pointA, to: pointB,steps: 6, angleInDegrees: 60)
        }
        points[6] = pointB
        jumpMan.jumpingPoints = points

        
    }
    
    func jumpLeft() {
        jumpMan.isJumping = true
    }
    
    func jumpRight() {
        jumpMan.isJumping = true

    }
    
    func animateJumpMan(){
        guard jumpMan.isWalking || jumpMan.isClimbing || jumpMan.isJumping else {
            return
        }
        if jmAnimationCounter == jumpMan.animationFrames {
            if jumpMan.isWalking {
                jumpMan.startedClimbing = false
                if jumpMan.facing == .right {
                    animateJMRight()
                } else {
                    animateJMLeft()
                }
            } else if jumpMan.isClimbing {
                if jumpMan.isClimbingUp {
                    if !jumpMan.startedClimbing {
                        jumpMan.startedClimbing = true
                    }
                    animateJMUp()
                } else {
                    if !jumpMan.startedClimbing {
                        jumpMan.startedClimbing = true
                    }
                    animateJMDown()
                }
            } else if jumpMan.isJumping {
                animateJMJumping()
            }
            jmAnimationCounter = 0
        }
        jmAnimationCounter += 1
    }
    
    func animateJMJumping() {
        jumpMan.currentFrame = ImageResource(name: "JM2", bundle: .main)
        if jumpMan.isJumpingUp {
            jumpMan.position.y = jumpMan.jumpingPoints[jumpMan.jumpingFrame].y
        } else {
            jumpMan.position = jumpMan.jumpingPoints[jumpMan.jumpingFrame]
        }
        jumpMan.jumpingFrame += 1
        if jumpMan.jumpingFrame == jumpMan.jumpingPoints.count {
            jumpMan.jumpingFrame = 0
            jumpMan.jumpingPoints.removeAll()
            if jumpMan.isJumpingLeft {
                jumpMan.xPos -= 2
                jumpMan.isJumpingLeft = false
            } else if jumpMan.isJumpingRight {
                jumpMan.xPos += 2
                jumpMan.isJumpingRight = false
            }
            jumpMan.isJumping = false
            jumpMan.isJumpingUp = false
            jumpMan.currentFrame = ImageResource(name: "JM1", bundle: .main)
            currentHeightOffset = screenData[jumpMan.yPos][jumpMan.xPos].assetOffset
            jumpMan.position = calcPositionFromScreen(xPos: jumpMan.xPos,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
        }

    }
    
    

    
    func walkRight() {
        guard canMoveRight() else {
            jumpMan.isWalking = false
            jumpMan.isWalkingRight = false
            return
        }
        jumpMan.isWalking = true
        jumpMan.facing = .right
        animateJMRight()
        currentHeightOffset = screenData[jumpMan.yPos][jumpMan.xPos].assetOffset
        if currentHeightOffset != screenData[jumpMan.yPos][jumpMan.xPos+1].assetOffset {
            if currentHeightOffset > screenData[jumpMan.yPos][jumpMan.xPos+1].assetOffset {
                jumpMan.position.y += self.assetOffset
            } else {
                jumpMan.position.y -= self.assetOffset
            }
        }
    }
    
    func walkLeft() {
        guard canMoveLeft() else {
            jumpMan.isWalking = false
            jumpMan.isWalkingLeft = false
            return
        }
        jumpMan.isWalking = true
        jumpMan.facing = .left
        animateJMLeft()
        currentHeightOffset = screenData[jumpMan.yPos][jumpMan.xPos].assetOffset
        if currentHeightOffset != screenData[jumpMan.yPos][jumpMan.xPos-1].assetOffset {
            if currentHeightOffset > screenData[jumpMan.yPos][jumpMan.xPos-1].assetOffset {
                jumpMan.position.y += self.assetOffset
            } else {
                jumpMan.position.y -= self.assetOffset
            }
        }
    }
    
    func animateJMRight(){
        jumpMan.position.x += assetDimention / 3.0
        if jumpMan.hasHammer {
            jumpMan.currentFrame = jumpMan.hammerFrame == false ? jumpMan.hammer1[jumpMan.animateFrame] : jumpMan.hammer2[jumpMan.animateFrame]
        } else {
            jumpMan.currentFrame = jumpMan.walking[jumpMan.animateFrame]
        }
        jumpMan.animateFrame += 1
        if jumpMan.animateFrame == 3 {
            jumpMan.animateFrame = 0
            jumpMan.isWalking = false
            jumpMan.hammerFrame = !jumpMan.hammerFrame
            if jumpMan.xPos < screenDimentionX {
                jumpMan.xPos += 1
            }
            if jumpMan.willJump {
                jumpMan.isJumping = true
                jumpMan.isJumpingRight = true
                jump()
            }
            whatsAround()
        }
    }
    
    func animateJMLeft(){
        jumpMan.position.x -= assetDimention / 3.0
        if jumpMan.hasHammer {
            jumpMan.currentFrame = jumpMan.hammerFrame == false ? jumpMan.hammer1[jumpMan.animateFrame] : jumpMan.hammer2[jumpMan.animateFrame]
        } else {
            jumpMan.currentFrame = jumpMan.walking[jumpMan.animateFrame]
        }
        jumpMan.animateFrame += 1
        if jumpMan.animateFrame == 3 {
            jumpMan.animateFrame = 0
            jumpMan.isWalking = false
            jumpMan.hammerFrame = !jumpMan.hammerFrame
            if jumpMan.xPos > 0 {
                jumpMan.xPos -= 1
            }
            if jumpMan.willJump {
                jumpMan.isJumping = true
                jumpMan.isJumpingLeft = true
                jump()
            }

            whatsAround()
        }
    }
    
    func animateJMUp(){
        jumpMan.position.y -= ladderStep / 4.0
        jumpMan.currentFrame = jumpMan.climbing[jumpMan.animateFrame]
        jumpMan.animateFrame += 1
        if jumpMan.facing == .left {
            jumpMan.facing = .right
        } else {
            jumpMan.facing = .left
        }
        if jumpMan.animateFrame == 4 {
            jumpMan.animateFrame = 0
            jumpMan.isClimbing = false
            jumpMan.isClimbingUp = false
            if jumpMan.yPos != 0 {
                jumpMan.yPos -= 1
                currentHeightOffset = screenData[jumpMan.yPos][jumpMan.xPos].assetOffset
            }
            if !isLadderAbove() {
                jumpMan.currentFrame = ImageResource(name: "JMBack", bundle: .main)
                jumpMan.isClimbing = false
                jumpMan.isClimbingUp = false
            }
            whatsAround()
        }
    }
    
    func animateJMDown() {
        jumpMan.position.y += ladderStep / 4.0
        jumpMan.currentFrame = jumpMan.climbing[jumpMan.animateFrame]
        jumpMan.animateFrame += 1
        if jumpMan.facing == .left {
            jumpMan.facing = .right
        } else {
            jumpMan.facing = .left
        }
        if jumpMan.animateFrame == 4 {
            jumpMan.animateFrame = 0
            jumpMan.isClimbing = false
            jumpMan.isClimbingDown = false
            if jumpMan.yPos < screenDimentionY - 1 {
                jumpMan.yPos += 1
                currentHeightOffset = screenData[jumpMan.yPos][jumpMan.xPos].assetOffset
            }
            if !isLadderBelow() {
                jumpMan.currentFrame = ImageResource(name: "JMBack", bundle: .main)
                jumpMan.isClimbing = false
                jumpMan.isClimbingDown = false
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
        ladderHeight = jumpMan.position.y - endPosition.y
        ladderStep = ladderHeight / Double(yCount + 1)
    }
    
    func calculateLadderHeightDown() {
        jumpMan.animateFrame = 0
        var yCount = 0
        while screenData[jumpMan.yPos+yCount+1][jumpMan.xPos].assetType == .ladder {
            yCount += 1
        }
        let endPosition = calcPositionFromScreen(xPos: jumpMan.xPos, yPos: jumpMan.yPos+(yCount+1),frameSize: jumpMan.frameSize)
        ladderHeight = endPosition.y - jumpMan.position.y
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
        jumpMan.isClimbing = true
        animateJMUp()
    }
    
    func climbDown() {
        jumpMan.isClimbing = true
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
        guard jumpMan.xPos > 0 || !jumpMan.willJump else {
            return false
        }
        if screenData[jumpMan.yPos][jumpMan.xPos - 1].assetType != .blank {
            return true
        }
        return false
    }
    
    func canMoveRight() -> Bool {
        guard jumpMan.xPos < screenDimentionX - 2 || !jumpMan.willJump else {
            return false
        }
        if screenData[jumpMan.yPos][jumpMan.xPos + 1].assetType != .blank {
            return true
        }
        return false
    }
    
    func canClimbLadder() -> Bool {
        guard isLadderAbove() && !jumpMan.isClimbing else {
            return false
        }
        return true
    }
    
    func canDecendLadder() -> Bool {
        guard isLadderBelow() && !jumpMan.isClimbing else {
            return false
        }
        return true
    }
    
    func canStandFromLadder() -> Bool {
        guard jumpMan.isClimbing else {
            return false
        }
        if jumpMan.isClimbingUp {
            if screenData[jumpMan.yPos - 1][jumpMan.xPos].assetType == .girder {
                return true
            }
        } else if jumpMan.isClimbingDown {
            if screenData[jumpMan.yPos + 1][jumpMan.xPos].assetType == .girder {
                return true
            }
        }
        return false
    }
    
    func whatsAround() {
        return
        print("JumpMan Current position is X \(jumpMan.xPos) Y \(jumpMan.yPos)")
        print("JumpMan Current screen position is \(jumpMan.position)")
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
