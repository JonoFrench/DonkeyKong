//
//  GameManager.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import Foundation
import QuartzCore
import SwiftUI
import Combine

enum GameState {
    case intro,kongintro,howhigh,playing,ended,highscore,levelend
}

class GameManager: ObservableObject {
    let soundFX:SoundFX = SoundFX()
    let hiScores:DonkeyKongHighScores = DonkeyKongHighScores()
    @Published
    var gameScreen:ScreenData = ScreenData()
    
    var assetDimention = 0.0
    var assetOffset = 0.0
    var verticalOffset = 0.0
    var gameSize = CGSize()
    var screenSize = CGSize()
    @Published
    var screenData:[[ScreenAsset]] = [[]]
    @Published
    var gameState:GameState = .intro
    @Published
    var lives = 3
    var score = 0
    var level = 1
//    @Published
//    var introCounter = 0
    @Published
    var bonus = 5000
    ///Sprites of sorts....
    @ObservedObject
    var jumpMan:JumpMan = JumpMan(xPos: 0, yPos: 0, frameSize: CGSize(width: 32, height:  32))
    var kong:Kong = Kong(xPos: 0, yPos: 0, frameSize: CGSize(width: 72, height:  72))
    var pauline:Pauline = Pauline(xPos: 0, yPos: 0, frameSize: CGSize(width: 63, height:  36))
    let heartBeat = 0.6
    var flames:Flames = Flames(xPos: 0, yPos: 0, frameSize: CGSize(width: 24, height:  24))
    var collectibles:[Collectible] = []
    @ObservedObject
    var barrelArray:BarrelArray = BarrelArray()
    @ObservedObject
    var fireBlobArray:FireBlobArray = FireBlobArray()
    
    let heart = Collectible(type: .heart, xPos: 15, yPos: 2)
    var levelEnd = false
    var hasFlames = false
    var explosion:Explode = Explode(xPos: 0, yPos: 0, frameSize: CGSize(width: 32, height:  32))
    @Published
    var hasExplosion = false
    var pointsShow:Points = Points(xPos: 0, yPos: 0, frameSize: CGSize(width: 32, height:  32))
    @Published
    var hasPoints = false
    var pause = false
    
    init() {
        /// Share these instances so they are available from the Sprites
        ServiceLocator.shared.register(service: gameScreen)
        ServiceLocator.shared.register(service: fireBlobArray)
        ServiceLocator.shared.register(service: barrelArray)
        
        ///Here we go, lets have a nice DisplayLink to update our model with the screen refresh.
        let displayLink:CADisplayLink = CADisplayLink(target: self, selector: #selector(refreshModel))
        displayLink.add(to: .main, forMode:.common)
        notificationObservers()
        
    }
    
    func addPoints(value:Int,position:CGPoint) {
        hasPoints = true
        pointsShow.pointsText = "\(value)"
        score += value
        pointsShow.position = position
        pointsShow.animateCounter = 0
    }
    
    @objc func refreshModel() {
        if gameState == .kongintro {
            if kong.state == .intro {
                kong.animateIntro()
            } else if kong.state == .jumpingup {
                kong.animateJumpUp()
                if kong.showPauline {
                    pauline.isShowing = true
                }
            } else if kong.state == .bouncing {
                kong.animateHop()
            }
        }
        
        if gameState == .playing {
            if !pause {
                moveJumpMan()
                animateJumpMan()
                pauline.animate()
                if hasFlames {
                    flames.animate()
                }
                if level == 1 {
                    throwBarrel()
                    
                    for barrel in barrelArray.barrels {
                        barrel.animate()
                        if !barrel.isThrown {
                            barrel.move()
                        } else {
                            barrel.moveThrown()
                        }
                    }
                    
                    for fireBlob in fireBlobArray.fireblob {
                        fireBlob.animate()
                        if fireBlob.state == .hopping {
                            fireBlob.hop()
                        } else {
                            fireBlob.move()
                        }
                    }
                }
                if levelEnd {
                    kong.animateExit()
                    flames.animate()
                }
                
                if collectibles.count > 0 {
                    checkCollectibles()
                }
            }
            if hasExplosion {
                explosion.animate()
            }
            if hasPoints {
                pointsShow.animate()
            }
        }
    }
    
    func startGame() {
        assetDimention = gameSize.width / Double(gameScreen.screenDimentionX - 1)
        assetOffset = assetDimention / 8.0
        verticalOffset =  -50.0 //(gameSize.height - (assetDimention * 25.0))
        gameScreen.assetDimention = gameSize.width / Double(gameScreen.screenDimentionX - 1)
        gameScreen.assetOffset = assetDimention / 8.0
        gameScreen.verticalOffset =  -50.0 //(gameSize.height - (assetDimention * 25.0))
        setKongIntro()   // If we don't want the intro....
        //startPlaying()
    }
    
    func startPlaying() {
        levelEnd = false
        bonus = 4000
        setDataForLevel()
        gameState = .playing
        startBonusCountdown()
        kong.currentFrame = kong.kongFacing
        kong.state = .sitting
        //startHeartBeat()
        if level == 1 {
            kong.isThrowing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                throwBarrelDown()
            }
        }
        whatsAround()
    }
    
    func setDataForLevel() {
        collectibles.removeAll()
        barrelArray.barrels.removeAll()
        fireBlobArray.fireblob.removeAll()
        screenData = Screens().getScreenData(level: self.level)
        gameScreen.screenData = Screens().getScreenData(level: self.level)
        if level == 1 {
            jumpMan.xPos = 6
            jumpMan.yPos = 27
            //jumpMan.hasHammer = true
            jumpMan.position = calcPositionFromScreen(xPos: jumpMan.xPos,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
            pauline.setPosition(xPos: 14, yPos: 3)
            
            kong.setPosition(xPos: 6, yPos: 7)
//            kong.xPos = 6
//            kong.yPos = 7
//            kong.position = calcPositionFromScreen(xPos: kong.xPos,yPos: kong.yPos,frameSize: kong.frameSize)
//            kong.position.y += 7
            pauline.isShowing = true
            flames.setPosition(xPos: 4, yPos: 25)
            hasFlames = false
            collectibles.append(Collectible(type: .hammer, xPos: 3, yPos: 9))
            collectibles.append(Collectible(type: .hammer, xPos: 20, yPos: 21))
        } else if level == 2 {
            jumpMan.xPos = 3
            jumpMan.yPos = 27
            jumpMan.facing = .right
            jumpMan.position = calcPositionFromScreen(xPos: jumpMan.xPos,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
            kong.setPosition(xPos: 14, yPos: 7)
//            kong.xPos = 14
//            kong.yPos = 7
//            kong.position = calcPositionFromScreen(xPos: kong.xPos,yPos: kong.yPos,frameSize: kong.frameSize)
//            kong.position.y += 7
            
            pauline.setPosition(xPos: 15, yPos: 2)

//            pauline.xPos = 15
//            pauline.yPos = 2
//            pauline.position = calcPositionFromScreen(xPos: pauline.xPos,yPos: pauline.yPos,frameSize: pauline.frameSize)
            pauline.isShowing = true
            hasFlames = false
            collectibles.append(Collectible(type: .hammer, xPos: 14, yPos: 10))
            collectibles.append(Collectible(type: .hammer, xPos: 2, yPos: 15))
            collectibles.append(Collectible(type: .umbrella, xPos: 4, yPos: 7))
            collectibles.append(Collectible(type: .hat, xPos: 26, yPos: 22))
            collectibles.append(Collectible(type: .phone, xPos: 17, yPos: 27))
            
            //flames = Flames(xPos: 0, yPos: 0, frameSize: CGSize(width: 24, height:  24))
            
        } else if level == 3 {
            jumpMan.xPos = 3
            jumpMan.yPos = 27
            jumpMan.facing = .right
            jumpMan.position = calcPositionFromScreen(xPos: jumpMan.xPos,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
            kong.setPosition(xPos: 21, yPos: 7)
//            kong.xPos = 21
//            kong.yPos = 7
//            kong.position = calcPositionFromScreen(xPos: kong.xPos,yPos: kong.yPos,frameSize: kong.frameSize)
//            kong.position.y += 7
            
            pauline.setPosition(xPos: 14, yPos: 3)
            pauline.isShowing = true
            
            flames.setPosition(xPos: 15, yPos: 12)
            hasFlames = true
            
            collectibles.append(Collectible(type: .hammer, xPos: 14, yPos: 20))
            collectibles.append(Collectible(type: .hammer, xPos: 3, yPos: 15))
            collectibles.append(Collectible(type: .umbrella, xPos: 24, yPos: 17))
            collectibles.append(Collectible(type: .hat, xPos: 9, yPos: 17))
            collectibles.append(Collectible(type: .phone, xPos: 16, yPos: 27))
        } else if level == 4 {
            jumpMan.xPos = 1
            jumpMan.yPos = 25
            jumpMan.facing = .right
            jumpMan.position = calcPositionFromScreen(xPos: jumpMan.xPos,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
            pauline.setPosition(xPos: 14, yPos: 3)
            pauline.isShowing = true
            kong.setPosition(xPos: 21, yPos: 7)
//            kong.xPos = 6
//            kong.yPos = 7
//            kong.position = calcPositionFromScreen(xPos: kong.xPos,yPos: kong.yPos,frameSize: kong.frameSize)
//            kong.position.y += 7
            collectibles.append(Collectible(type: .phone, xPos: 27, yPos: 9))
            collectibles.append(Collectible(type: .umbrella, xPos: 1, yPos: 13))
            collectibles.append(Collectible(type: .hat, xPos: 9, yPos: 22))
        }
    }
    
    func startBonusCountdown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            bonus -= 100
            if bonus > 0 {
                startBonusCountdown()
            }
        }
    }
    /// todo change the time to 30 seconds
    func startHammerCountdown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [self] in
            jumpMan.hasHammer = false
            jumpMan.frameSize = jumpMan.normalFrameSize
            jumpMan.currentFrame = ImageResource(name: "JM1", bundle: .main)
            jumpMan.position = calcPositionFromScreen(xPos: jumpMan.xPos,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
            jumpMan.objectWillChange.send()
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
            points = jumpMan.generateParabolicPoints(from: pointA, to: pointB,steps: 6, angleInDegrees: -60)
        } else {
            pointB = calcPositionFromScreen(xPos: jumpMan.xPos + 2,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
            points = jumpMan.generateParabolicPoints(from: pointA, to: pointB,steps: 6, angleInDegrees: 60)
        }
        points[6] = pointB
        jumpMan.jumpingPoints = points
        soundFX.jumpSound()
    }
    
    func jumpLeft() {
        jumpMan.isJumping = true
    }
    
    func jumpRight() {
        jumpMan.isJumping = true
    }
    
    func animateJumpMan(){
        guard jumpMan.isWalking || jumpMan.isClimbing || jumpMan.isJumping || jumpMan.hasHammer else {
            return
        }
        if jumpMan.speedCounter == jumpMan.speed {
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
            if jumpMan.hasHammer {
                animateHammer()
            }
            jumpMan.speedCounter = 0
        }
        jumpMan.speedCounter += 1
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
            if jumpMan.hasHammer {
                jumpMan.frameSize = jumpMan.hammerFrameSize
                jumpMan.currentFrame = ImageResource(name: "JMHam1", bundle: .main)
            } else {
                jumpMan.currentFrame = ImageResource(name: "JM1", bundle: .main)
                
            }
            jumpMan.currentHeightOffset = screenData[jumpMan.yPos][jumpMan.xPos].assetOffset
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
        jumpMan.currentHeightOffset = screenData[jumpMan.yPos][jumpMan.xPos].assetOffset
        if jumpMan.currentHeightOffset != screenData[jumpMan.yPos][jumpMan.xPos+1].assetOffset {
            if jumpMan.currentHeightOffset > screenData[jumpMan.yPos][jumpMan.xPos+1].assetOffset {
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
        jumpMan.currentHeightOffset = screenData[jumpMan.yPos][jumpMan.xPos].assetOffset
        if jumpMan.currentHeightOffset != screenData[jumpMan.yPos][jumpMan.xPos-1].assetOffset {
            if jumpMan.currentHeightOffset > screenData[jumpMan.yPos][jumpMan.xPos-1].assetOffset {
                jumpMan.position.y += self.assetOffset
            } else {
                jumpMan.position.y -= self.assetOffset
            }
        }
    }
    
    func animateHammer(){
        if jumpMan.isWalking {
            jumpMan.currentFrame = jumpMan.hammerWalking[jumpMan.animateHammerFrame]
        } else {
            jumpMan.currentFrame = jumpMan.hammer1[jumpMan.animateHammerFrame]
        }
        jumpMan.frameSize = jumpMan.hammerFrameSize
        jumpMan.animateHammerFrame += 1
        if jumpMan.animateHammerFrame == 16 {
            jumpMan.animateHammerFrame = 0
        }
    }
    
    func animateJMRight(){
        jumpMan.position.x += assetDimention / 3.0
        if !jumpMan.hasHammer {
            jumpMan.currentFrame = jumpMan.walking[jumpMan.animateFrame]
        }
        jumpMan.animateFrame += 1
        if jumpMan.animateFrame == 3 {
            jumpMan.animateFrame = 0
            jumpMan.isWalking = false
            if jumpMan.xPos < gameScreen.screenDimentionX {
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
        if !jumpMan.hasHammer {
            jumpMan.currentFrame = jumpMan.walking[jumpMan.animateFrame]
        }
        jumpMan.animateFrame += 1
        if jumpMan.animateFrame == 3 {
            jumpMan.animateFrame = 0
            jumpMan.isWalking = false
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
        jumpMan.position.y -= jumpMan.ladderStep / 4.0
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
                jumpMan.currentHeightOffset = screenData[jumpMan.yPos][jumpMan.xPos].assetOffset
            }
            if !isLadderAbove() {
                jumpMan.currentFrame = ImageResource(name: "JMBack", bundle: .main)
                jumpMan.isClimbing = false
                jumpMan.isClimbingUp = false
                levelComplete()
            }
            whatsAround()
        }
    }
    
    func animateJMDown() {
        jumpMan.position.y += jumpMan.ladderStep / 4.0
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
            if jumpMan.yPos < gameScreen.screenDimentionY - 1 {
                jumpMan.yPos += 1
                jumpMan.currentHeightOffset = screenData[jumpMan.yPos][jumpMan.xPos].assetOffset
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
        jumpMan.ladderHeight = jumpMan.position.y - endPosition.y
        jumpMan.ladderStep = jumpMan.ladderHeight / Double(yCount + 1)
    }
    
    func calculateLadderHeightDown() {
        jumpMan.animateFrame = 0
        var yCount = 0
        while screenData[jumpMan.yPos+yCount+1][jumpMan.xPos].assetType == .ladder {
            yCount += 1
        }
        let endPosition = calcPositionFromScreen(xPos: jumpMan.xPos, yPos: jumpMan.yPos+(yCount+1),frameSize: jumpMan.frameSize)
        jumpMan.ladderHeight = endPosition.y - jumpMan.position.y
        jumpMan.ladderStep = jumpMan.ladderHeight / Double(yCount+1)
    }
    
    func calcPositionForAsset(xPos:Int, yPos:Int) -> CGPoint  {
        let assetOffsetAtPosition = gameScreen.screenData[yPos][xPos].assetOffset
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
        if jumpMan.yPos <= gameScreen.screenDimentionY - 2 {
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
        guard jumpMan.xPos < gameScreen.screenDimentionX - 2 || !jumpMan.willJump else {
            return false
        }
        if screenData[jumpMan.yPos][jumpMan.xPos + 1].assetType != .blank {
            return true
        }
        return false
    }
    
    func canClimbLadder() -> Bool {
        if jumpMan.hasHammer { return false }
        guard isLadderAbove() && !jumpMan.isClimbing else {
            return false
        }
        return true
    }
    
    func canDecendLadder() -> Bool {
        if jumpMan.hasHammer { return false }
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
    
    func levelComplete(){
        guard jumpMan.xPos == 17 && jumpMan.yPos == 3 else {
            return
        }
        heart.position = calcPositionFromScreen(xPos: heart.xPos,yPos: heart.yPos,frameSize: heart.frameSize)
        collectibles.removeAll()
        collectibles.append(heart)
        jumpMan.currentFrame = ImageResource(name: "JM1", bundle: .main)
        jumpMan.facing = .left
        barrelArray.barrels.removeAll()
        kong.isThrowing = true
        pauline.isRescued = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            levelEnd = true
            heart.type = .heartbreak
            self.heart.objectWillChange.send()
            kong.exitLevel()
            pauline.isShowing = false
        }
    }
    
    func checkCollectibles() {
        for collectible in collectibles {
            if !collectible.collected {
                if circlesIntersect(center1: jumpMan.position, diameter1: jumpMan.frameSize.width / 2, center2: collectible.position, diameter2: collectible.frameSize.width / 2) {
                    collectible.collected = true
                    soundFX.getItemSound()
                    if collectible.collectibleScore() > 0 {
                        addPoints(value: collectible.collectibleScore(), position: collectible.position)
                    } else if collectible.type == .hammer {
                        setHammer()
                    }
                }
            }
        }
    }
    
    func setHammer() {
        jumpMan.hasHammer = true
        jumpMan.animateHammerFrame = 0
        startHammerCountdown()
    }
    
    func circlesIntersect(center1: CGPoint, diameter1: CGFloat, center2: CGPoint, diameter2: CGFloat) -> Bool {
        let radius1 = diameter1 / 2
        let radius2 = diameter2 / 2
        
        let distanceX = center2.x - center1.x
        let distanceY = center2.y - center1.y
        let distanceSquared = distanceX * distanceX + distanceY * distanceY
        let radiusSum = radius1 + radius2
        let radiusSumSquared = radiusSum * radiusSum
        
        return distanceSquared <= radiusSumSquared
    }
    
    func whatsAround() {
        return
        print("JumpMan Current position is X \(jumpMan.xPos) Y \(jumpMan.yPos)")
        print("JumpMan Current screen position is \(jumpMan.position)")
        print("JumpMan Current height offset is \(jumpMan.currentHeightOffset)")
        print("Current Standing on is \(screenData[jumpMan.yPos][jumpMan.xPos].assetType)")
        if jumpMan.xPos == 0 {
            print("Nothing Behind")
        } else {
            print("Behind is \(screenData[jumpMan.yPos-1][jumpMan.xPos - 1].assetType)")
        }
        if jumpMan.xPos > gameScreen.screenDimentionX {
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
