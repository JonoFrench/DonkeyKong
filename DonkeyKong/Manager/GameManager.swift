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
    var introCounter = 0
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
    var kong:Kong = Kong()
    var pauline:Pauline = Pauline()
    let heartBeat = 0.6
    var flames:Flames = Flames()
    var collectibles:[Collectible] = []
    @ObservedObject
    var barrelArray:BarrelArray = BarrelArray()
    let heart = Collectible(type: .heart, xPos: 15, yPos: 2)
    var levelEnd = false
    var hasFlames = false
    var explosion:Explode = Explode()
    @Published
    var hasExplosion = false
    var pointsShow:Points = Points()
    @Published
    var hasPoints = false
    var pause = false
    
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
                            moveBarrel(barrel: barrel)
                        } else {
                            moveThrownBarrel(barrel: barrel)
                        }
                    }
                }
                if levelEnd {
                    animateKongExit()
                    flames.animate()
                }
                
                if collectibles.count > 0 {
                    checkCollectibles()
                }
            }
            if hasExplosion {
                animateExplosion()
            }
            if hasPoints {
                animatePoints()
            }

            
        }
    }
    
    func startGame() {
        assetDimention = gameSize.width / Double(screenDimentionX - 1)
        assetOffset = assetDimention / 8.0
        verticalOffset =  -50.0 //(gameSize.height - (assetDimention * 25.0))
        print("assetDimention \(assetDimention)")
        print("assetOffset \(assetOffset)")
        print("verticalOffset \(verticalOffset)")
        //setKongIntro()   // If we don't want the intro....
        startPlaying()
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
        screenData = Screens().getScreenData(level: self.level)
        
        if level == 1 {
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
            flames.xPos = 4
            flames.yPos = 25
            flames.position = calcPositionFromScreen(xPos: flames.xPos,yPos: flames.yPos,frameSize: flames.frameSize)
            flames.position.y += 4
            flames.position.x -= 8
            hasFlames = true
            let collectible1 = Collectible(type: .hammer, xPos: 3, yPos: 9)
            collectible1.position = calcPositionFromScreen(xPos: collectible1.xPos,yPos: collectible1.yPos,frameSize: collectible1.frameSize)
            let collectible2 = Collectible(type: .hammer, xPos: 20, yPos: 21)
            collectible2.position = calcPositionFromScreen(xPos: collectible2.xPos,yPos: collectible2.yPos,frameSize: collectible2.frameSize)
            collectibles.append(collectible1)
            collectibles.append(collectible2)
        } else if level == 2 {
            jumpMan.xPos = 3
            jumpMan.yPos = 27
            jumpMan.facing = .right
            jumpMan.position = calcPositionFromScreen(xPos: jumpMan.xPos,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
            kong.xPos = 14
            kong.yPos = 7
            kong.position = calcPositionFromScreen(xPos: kong.xPos,yPos: kong.yPos,frameSize: kong.frameSize)
            kong.position.y += 7
            
            pauline.xPos = 15
            pauline.yPos = 2
            pauline.position = calcPositionFromScreen(xPos: pauline.xPos,yPos: pauline.yPos,frameSize: pauline.frameSize)
            pauline.isShowing = true
            hasFlames = false
            let collectible1 = Collectible(type: .hammer, xPos: 14, yPos: 10)
            collectible1.position = calcPositionFromScreen(xPos: collectible1.xPos,yPos: collectible1.yPos,frameSize: collectible1.frameSize)
            let collectible2 = Collectible(type: .hammer, xPos: 1, yPos: 15)
            collectible2.position = calcPositionFromScreen(xPos: collectible2.xPos,yPos: collectible2.yPos,frameSize: collectible2.frameSize)
            let collectible3 = Collectible(type: .umbrella, xPos: 4, yPos: 7)
            collectible3.position = calcPositionFromScreen(xPos: collectible3.xPos,yPos: collectible3.yPos,frameSize: collectible3.frameSize)
            let collectible4 = Collectible(type: .hat, xPos: 26, yPos: 22)
            collectible4.position = calcPositionFromScreen(xPos: collectible4.xPos,yPos: collectible4.yPos,frameSize: collectible4.frameSize)
            let collectible5 = Collectible(type: .phone, xPos: 17, yPos: 27)
            collectible5.position = calcPositionFromScreen(xPos: collectible5.xPos,yPos: collectible5.yPos,frameSize: collectible5.frameSize)
            
            collectibles.append(collectible1)
            collectibles.append(collectible2)
            collectibles.append(collectible3)
            collectibles.append(collectible4)
            collectibles.append(collectible5)
            
            flames = Flames()
            
        } else if level == 3 {
            jumpMan.xPos = 3
            jumpMan.yPos = 27
            jumpMan.facing = .right
            jumpMan.position = calcPositionFromScreen(xPos: jumpMan.xPos,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
            kong.xPos = 21
            kong.yPos = 7
            kong.position = calcPositionFromScreen(xPos: kong.xPos,yPos: kong.yPos,frameSize: kong.frameSize)
            kong.position.y += 7
            
            pauline.xPos = 14
            pauline.yPos = 3
            pauline.position = calcPositionFromScreen(xPos: pauline.xPos,yPos: pauline.yPos,frameSize: pauline.frameSize)
            pauline.isShowing = true
            
            flames.xPos = 15
            flames.yPos = 12
            
            flames.position = calcPositionFromScreen(xPos: flames.xPos,yPos: flames.yPos,frameSize: flames.frameSize)
            flames.position.y += 4
            flames.position.x -= 8
            hasFlames = true
            
            let collectible1 = Collectible(type: .hammer, xPos: 14, yPos: 20)
            collectible1.position = calcPositionFromScreen(xPos: collectible1.xPos,yPos: collectible1.yPos,frameSize: collectible1.frameSize)
            let collectible2 = Collectible(type: .hammer, xPos: 3, yPos: 15)
            collectible2.position = calcPositionFromScreen(xPos: collectible2.xPos,yPos: collectible2.yPos,frameSize: collectible2.frameSize)
            let collectible3 = Collectible(type: .umbrella, xPos: 24, yPos: 17)
            collectible3.position = calcPositionFromScreen(xPos: collectible3.xPos,yPos: collectible3.yPos,frameSize: collectible3.frameSize)
            let collectible4 = Collectible(type: .hat, xPos: 9, yPos: 17)
            collectible4.position = calcPositionFromScreen(xPos: collectible4.xPos,yPos: collectible4.yPos,frameSize: collectible4.frameSize)
            let collectible5 = Collectible(type: .phone, xPos: 16, yPos: 27)
            collectible5.position = calcPositionFromScreen(xPos: collectible5.xPos,yPos: collectible5.yPos,frameSize: collectible5.frameSize)
            
            collectibles.append(collectible1)
            collectibles.append(collectible2)
            collectibles.append(collectible3)
            collectibles.append(collectible4)
            collectibles.append(collectible5)
        } else if level == 4 {
            jumpMan.xPos = 1
            jumpMan.yPos = 25
            jumpMan.facing = .right
            jumpMan.position = calcPositionFromScreen(xPos: jumpMan.xPos,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
            pauline.xPos = 14
            pauline.yPos = 3
            pauline.position = calcPositionFromScreen(xPos: pauline.xPos,yPos: pauline.yPos,frameSize: pauline.frameSize)
            pauline.isShowing = true
            kong.xPos = 6
            kong.yPos = 7
            kong.position = calcPositionFromScreen(xPos: kong.xPos,yPos: kong.yPos,frameSize: kong.frameSize)
            kong.position.y += 7

            
            let collectible1 = Collectible(type: .phone, xPos: 27, yPos: 9)
            collectible1.position = calcPositionFromScreen(xPos: collectible1.xPos,yPos: collectible1.yPos,frameSize: collectible1.frameSize)
            let collectible2 = Collectible(type: .umbrella, xPos: 1, yPos: 13)
            collectible2.position = calcPositionFromScreen(xPos: collectible2.xPos,yPos: collectible2.yPos,frameSize: collectible2.frameSize)
            let collectible3 = Collectible(type: .hat, xPos: 9, yPos: 22)
            collectible3.position = calcPositionFromScreen(xPos: collectible3.xPos,yPos: collectible3.yPos,frameSize: collectible3.frameSize)
            collectibles.append(collectible1)
            collectibles.append(collectible2)
            collectibles.append(collectible3)

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
    /// todo change the time
    func startHammerCountdown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 120) { [self] in
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
    
    func animateExplosion() {
        explosion.animateCounter += 1
        if explosion.animateCounter == explosion.animateFrames {
            explosion.currentFrame = explosion.explosions[explosion.cFrame]
            explosion.cFrame += 1
            if explosion.cFrame == explosion.explosions.count {
                explosion.cFrame = 0
                hasExplosion = false
                if !hasPoints {
                    addPoints(value: 100, position: explosion.position)
                }
            }
            explosion.animateCounter = 0
        }
    }
    
    func addPoints(value:Int,position:CGPoint) {
        hasPoints = true
        pointsShow.pointsText = "\(value)"
        score += value
        pointsShow.position = position
        pointsShow.animateCounter = 0
    }
    
    /// not doing a lot but display the points colleted.
    func animatePoints() {
        pointsShow.animateCounter += 1
        if pointsShow.animateCounter == pointsShow.animateFrames {
            //pointsShow.pointsColor = pointsShow.animateCounter % 1 == 0 ? .black : .white
            pointsShow.cFrame += 1
            if pointsShow.cFrame == 6 {
                pointsShow.cFrame = 0
                hasPoints = false
            }
            pointsShow.animateCounter = 0
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
            points = generateParabolicPoints(from: pointA, to: pointB,steps: 6, angleInDegrees: -60)
        } else {
            pointB = calcPositionFromScreen(xPos: jumpMan.xPos + 2,yPos: jumpMan.yPos,frameSize: jumpMan.frameSize)
            points = generateParabolicPoints(from: pointA, to: pointB,steps: 6, angleInDegrees: 60)
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
                levelComplete()
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
            kongExitLevel()
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
