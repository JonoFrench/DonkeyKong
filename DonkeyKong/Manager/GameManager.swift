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
    case intro,getready,playing,ended,highscore
}

class GameManager: ObservableObject {
    let animationSpeed = 0.08
    let animationFrames = 6
    
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

    var jumpManXPos = 0
    var jumpManYPos = 0
    
    var jmAnimationCounter = 0

    init() {
        ///Here we go, lets have a nice DisplayLink to update our model with the screen refresh.
        let displayLink:CADisplayLink = CADisplayLink(target: self, selector: #selector(refreshModel))
        displayLink.add(to: .main, forMode:.common)
    }
    
    @objc func refreshModel() {
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
        screenData = Screens().getScreenData()
        
        jumpManXPos = 0
        jumpManYPos = 27
        //jumpMan.hasHammer = true
        jumpMan.jumpManPosition = jumpMan.calcPositionFromGrid(gameSize: gameSize, assetDimention: assetDimention,xPos: jumpManXPos,yPos: jumpManYPos,heightAdjust: screenData[jumpManXPos][jumpManYPos].assetOffset)
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
                if jumpMan.facing == .right {
                    animateJMRight()
                } else {
                    animateJMLeft()
                }
            } else if isClimbing {
                if isClimbingUp {
                    animateJMUp()
                } else {
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
        print("climbng up frame \(jumpMan.animateFrame)")
        jumpMan.jumpManPosition.y -= assetDimention / 3.0
//        if canStandFromLadder() {
//            jumpMan.currentFrame = jumpMan.climbing2[jumpMan.animateFrame]
//        } else {
            jumpMan.currentFrame = jumpMan.climbing[jumpMan.animateFrame]
//        }
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
        jumpMan.jumpManPosition.y += assetDimention / 3.0
//        if canStandFromLadder() {
//            jumpMan.currentFrame = jumpMan.climbing2[jumpMan.animateFrame]
//        } else {
            jumpMan.currentFrame = jumpMan.climbing[jumpMan.animateFrame]
//        }
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
    
    func walkLeft() {
        guard canMoveLeft() else {
            isWalking = false
            isWalkingLeft = false
            return
        }
        isWalking = true
        jumpMan.facing = .left
        animateJMLeft()
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
        if screenData[jumpManYPos - 1][jumpManXPos].assetType == .ladder || screenData[jumpManYPos][jumpManXPos].assetType == .ladder {
         return true
        }
        return false
    }
    
    func isLadderBelow() -> Bool {
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
