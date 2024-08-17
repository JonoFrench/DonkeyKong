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
    let animationSpeed = 0.08
    let animationFrames = 5
    
    let screenDimentionX = 30
    let screenDimentionY = 28
    var assetDimention = 0.0
    var assetOffset = 0.0
    var verticalOffset = 0.0
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
    var bonus = 0
    ///New High Score Handling
    @Published
    var letterIndex = 0
    @Published
    var letterArray:[Character] = ["A","A","A"]
    @Published
    var selectedLetter = 0
    
    var screenData:[[ScreenAsset]] = [[]]
    ///Sprites of sorts....
    @Published
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
    var jumpManXPos = 0
    var jumpManYPos = 0
    
    var jmAnimationCounter = 0
    
    @Published
    var kongIntroCounter = 0
    @Published
    var kong:Kong = Kong()
    var dkAnimationCounter = 0
    var dkBouncePos = 0
    var dkBounceYPos = 0
    var pauline:Pauline = Pauline()
    
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
    }
    
    func startPlaying() {
        screenData = Screens().getScreenData()
        jumpManXPos = 0
        jumpManYPos = 27
        //jumpMan.hasHammer = true
        jumpMan.jumpManPosition = jumpMan.calcPositionFromGrid(gameSize: gameSize, assetDimention: assetDimention,xPos: jumpManXPos,yPos: jumpManYPos,heightAdjust: screenData[jumpManXPos][jumpManYPos].assetOffset)
        pauline.xPos = 6
        pauline.yPos = 2
        pauline.paulinePosition = calcPositionFromGrid(gameSize: gameSize, assetDimention: assetDimention,xPos: pauline.xPos,yPos: pauline.yPos,heightAdjust: -4.0,frameSize: pauline.frameSize)
        kong.xPos = 2
        kong.yPos = 2


        kong.kongPosition = calcPositionFromGrid(gameSize: gameSize, assetDimention: assetDimention,xPos: kong.xPos,yPos: kong.yPos,heightAdjust: screenData[kong.xPos][kong.yPos].assetOffset,frameSize: kong.frameSize)
        
        pauline.paulinePosition.x += 4.0
        kong.kongPosition.x += 8.0 // cos theres an asset mod on the line
        kong.kongPosition.y -= 2.0 // cos theres an asset mod on the line
        pauline.isShowing = true
        gameState = .playing
        whatsAround()

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
    
    func getXnY(){
        let gridPosition = jumpMan.calcGridPositionFromPoint(gameSize: gameSize, assetDimention: assetDimention)
        print("xPos: \(gridPosition.xPos), yPos: \(gridPosition.yPos)")
        
    }
    
    func animateJumpMan(){
        guard isWalking || isClimbing else {
            return
        }
        if jmAnimationCounter == animationFrames {
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
                        calculateLadderHeightUp()
                        startedClimbing = true
                    }
                    animateJMUp()
                } else {
                    if !startedClimbing {
                        calculateLadderHeightDown()
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
        let currentHeight = screenData[jumpManYPos][jumpManXPos].assetOffset
        if currentHeight != screenData[jumpManYPos][jumpManXPos+1].assetOffset {
            if currentHeight > screenData[jumpManYPos][jumpManXPos+1].assetOffset {
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
        let currentHeight = screenData[jumpManYPos][jumpManXPos].assetOffset
        if currentHeight != screenData[jumpManYPos][jumpManXPos-1].assetOffset {
            if currentHeight > screenData[jumpManYPos][jumpManXPos-1].assetOffset {
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
            if jumpManXPos < screenDimentionX {
                jumpManXPos += 1
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
            if jumpManXPos > 0 {
                jumpManXPos -= 1
            }
            whatsAround()
        }
    }
    
    func animateJMUp(){
        jumpMan.jumpManPosition.y -= ladderStep / 3.0
        jumpMan.currentFrame = jumpMan.climbing[jumpMan.animateFrame]
        jumpMan.animateFrame += 1
        if jumpMan.animateFrame == 3 {
            jumpMan.animateFrame = 0
            isClimbing = false
            isClimbingUp = false
            if jumpManYPos != 0 {
                jumpManYPos -= 1
            }
            if !isLadderAbove() {
                jumpMan.currentFrame = ImageResource(name: "JMBack", bundle: .main)
            }
            whatsAround()
        }
    }
    
    func animateJMDown() {
        jumpMan.jumpManPosition.y += ladderStep / 3.0
        jumpMan.currentFrame = jumpMan.climbing[jumpMan.animateFrame]
        jumpMan.animateFrame += 1
        if jumpMan.animateFrame == 3 {
            jumpMan.animateFrame = 0
            isClimbing = false
            isClimbingDown = false
            
            if jumpManYPos < screenDimentionY - 1 {
                jumpManYPos += 1
            }
            if !isLadderBelow() {
                jumpMan.currentFrame = ImageResource(name: "JMBack", bundle: .main)
            }
        }
    }
    
    func calculateLadderHeightUp() {
        var yCount = 1
        while screenData[jumpManYPos-yCount][jumpManXPos].assetType == .ladder || jumpManYPos-yCount == 0 {
            yCount += 1
        }
        let startPosition = calcPositionForAsset(xPos: jumpManXPos, yPos: jumpManYPos)
        let endPosition = calcPositionForAsset(xPos: jumpManXPos, yPos: jumpManYPos-(yCount-1))
        ladderHeight = startPosition.y - endPosition.y
        ladderStep = ladderHeight / Double(yCount-1)
        print("Ladder Height Up \(ladderHeight) Step Height = \(ladderStep) yCount \(yCount) last type \(screenData[jumpManYPos-yCount][jumpManXPos].assetType) ")
    }
    
    func calcPositionForAsset(xPos:Int, yPos:Int) -> CGPoint  {
        let assetOffsetAtPosition = screenData[yPos][xPos].assetOffset
        return CGPoint(x: Double(xPos) * assetDimention + (assetDimention / 2), y: Double(yPos) * assetDimention - (assetOffset * assetOffsetAtPosition) + 80)
    }
    
    func calcPositionForXY(xPos:Int, yPos:Int, frameSize:CGSize) -> CGPoint  {
        return CGPoint(x: assetDimention * Double(xPos) + (frameSize.width / 2) + (assetDimention / 2), y: assetDimention * Double(yPos) - (frameSize.height / 2) - 80 - (assetDimention / 2))
    }
    
    func calculateLadderHeightDown() {
        var yCount = 1
        while screenData[jumpManYPos+yCount][jumpManXPos].assetType == .ladder {
            yCount += 1
        }
        let startPosition = calcPositionForAsset(xPos: jumpManXPos, yPos: jumpManYPos)
        let endPosition = calcPositionForAsset(xPos: jumpManXPos, yPos: jumpManYPos+(yCount-1))
        ladderHeight = endPosition.y - startPosition.y
        ladderStep = ladderHeight / Double(yCount-1)
        print("Ladder Height Down \(ladderHeight) Step Height = \(ladderHeight / 4) yCount \(yCount) last type \(screenData[jumpManYPos-yCount][jumpManXPos].assetType) ")
    }
    
    func climbUp() {
        isClimbing = true
        //        isClimbingUp = true
        animateJMUp()
    }
    
    func climbDown() {
        isClimbing = true
        //        isClimbingDown = true
        animateJMDown()
    }
    
    func isBlankAbove() -> Bool {
        if screenData[jumpManYPos - 1][jumpManXPos].assetType == .blank {
            return true
        }
        return false
    }
    
    func isLadderAbove() -> Bool {
        if screenData[jumpManYPos - 1][jumpManXPos].assetType == .blank { return false }
        if screenData[jumpManYPos - 1][jumpManXPos].assetType == .ladder || screenData[jumpManYPos][jumpManXPos].assetType == .ladder {
            return true
        }
        return false
    }
    
    func isLadderBelow() -> Bool {
        if screenData[jumpManYPos][jumpManXPos].assetType == .ladder { return true }
        if screenData[jumpManYPos][jumpManXPos].assetType == .blank { return false }
        if jumpManYPos <= screenDimentionY - 2 {
            if screenData[jumpManYPos + 1][jumpManXPos].assetType == .ladder || screenData[jumpManYPos + 1][jumpManXPos].assetType == .girder {
                return true
            } else {
                if screenData[jumpManYPos + 1][jumpManXPos].assetType == .girder {
                    return true
                }
            }
        }
        return false
    }
    
    //    jumpManXPos = 0
    //    jumpManYPos = 27
    
    func canMoveLeft() -> Bool {
        guard jumpManXPos > 0 else {
            return false
        }
        if screenData[jumpManYPos][jumpManXPos - 1].assetType != .blank {
            return true
        }
        return false
    }
    
    func canMoveRight() -> Bool {
        guard jumpManXPos < screenDimentionX - 2 else {
            return false
        }
        if screenData[jumpManYPos][jumpManXPos + 1].assetType != .blank {
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
            if screenData[jumpManYPos - 1][jumpManXPos].assetType == .girder {
                return true
            }
        } else if isClimbingDown {
            if screenData[jumpManYPos + 1][jumpManXPos].assetType == .girder {
                return true
            }
        }
        return false
    }
    
    
    func whatsAround() {
        //return
        print("Current position is X \(jumpManXPos) Y \(jumpManYPos)")
        //screenData[jumpManYPos][jumpManXPos].assetType = .oilBL
        print("Current Standing on is \(screenData[jumpManYPos][jumpManXPos].assetType)")
        if jumpManXPos == 0 {
            print("Nothing Behind")
        } else {
            print("Behind is \(screenData[jumpManYPos-1][jumpManXPos - 1].assetType)")
        }
        if jumpManXPos > screenDimentionX {
            print("Nothing In front")
        } else {
            print("In front is \(screenData[jumpManYPos-1][jumpManXPos + 1].assetType)")
        }
        if jumpManYPos == 0 {
            print("Nothing above")
        } else {
            print("Above is \(screenData[jumpManYPos - 1][jumpManXPos].assetType)")
        }
        if jumpManYPos == 27 {
            print("Nothing Below")
        } else {
            print("Below is \(screenData[jumpManYPos + 1][jumpManXPos].assetType)")
        }
        
        
    }
    
}
