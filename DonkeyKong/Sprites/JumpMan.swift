//
//  JumpMan.swift
//  DonkeyKong
//
//  Created by Jonathan French on 13.08.24.
//

import Foundation
import SwiftUI

enum JMState {
    case still,walking,climbingUp,climbingDown,hammer,dead
}
enum JMDirection {
    case left,right
}
final class JumpMan:SwiftUISprite,Moveable,Animatable, ObservableObject {
    static var animateFrames: Int = 0
    static var speed: Int = 3
    var speedCounter: Int = 0
    var animateCounter: Int = 0
    
    var isWalking = false
    var isWalkingRight = false
    var isWalkingLeft = false
    var isClimbing = false
    var isClimbingUp = false
    var isClimbingDown = false
    var startedClimbing = false
    var isJumping:Bool {
        didSet {
            if isJumping == true {
                jump()
            }
        }
    }
    var isJumpingUp:Bool {
        didSet {
            if isJumpingUp == true {
                isJumping = true
            }
        }
    }
    var isJumpingLeft = false
    var isJumpingRight = false
    var jumpingPoints = [CGPoint]()
    
    @Published
    var hasHammer = false
    var hammerFrameSize: CGSize = CGSize(width: 64, height:  64)
    var normalFrameSize: CGSize = CGSize(width: 32, height:  32)
    var animateFrame = 0
    var jumpingFrame = 0
    var animateHammerFrame = 0
    @Published
    var facing:JMDirection = .right
    
    var walking:[ImageResource] = [ImageResource(name: "JM2", bundle: .main),ImageResource(name: "JM3", bundle: .main),ImageResource(name: "JM1", bundle: .main)]
    var climbing:[ImageResource] = [ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb1", bundle: .main)]
    var climbing2:[ImageResource] = [ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb2", bundle: .main),ImageResource(name: "JMClimb3", bundle: .main),ImageResource(name: "JMBack", bundle: .main)]
    ///Certain frames i.e when hammer is down can kill barrels and fireblobs.
    var hammerDown:[Bool] = [false,false,false,false,true,true,true,true,false,false,false,false,true,true,true,true]
    var hammer1:[ImageResource] = [ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main)]
    var hammerWalking:[ImageResource] = [ImageResource(name: "JMHam3", bundle: .main),ImageResource(name: "JMHam3", bundle: .main),ImageResource(name: "JMHam3", bundle: .main),ImageResource(name: "JMHam3", bundle: .main),ImageResource(name: "JMHam4", bundle: .main),ImageResource(name: "JMHam4", bundle: .main),ImageResource(name: "JMHam4", bundle: .main),ImageResource(name: "JMHam4", bundle: .main),ImageResource(name: "JMHam5", bundle: .main),ImageResource(name: "JMHam5", bundle: .main),ImageResource(name: "JMHam5", bundle: .main),ImageResource(name: "JMHam5", bundle: .main),ImageResource(name: "JMHam6", bundle: .main),ImageResource(name: "JMHam6", bundle: .main),ImageResource(name: "JMHam6", bundle: .main),ImageResource(name: "JMHam6", bundle: .main)]
    
    override init(xPos: Int, yPos: Int, frameSize: CGSize) {
        isJumping = false
        isJumpingUp = false
        super.init(xPos: xPos, yPos: yPos, frameSize: frameSize)
        currentFrame = ImageResource(name: "JM1", bundle: .main)
    }
    
    func animate(){
        guard isWalking || isClimbing || isJumping || hasHammer else {
            return
        }
        if speedCounter == JumpMan.speed {
            if isWalking  && !isJumping {
                startedClimbing = false
                if facing == .right {
                    animateRight()
                } else {
                    animateLeft()
                }
            } else if isClimbing {
                if isClimbingUp {
                    if !startedClimbing {
                        startedClimbing = true
                    }
                    animateUp()
                } else {
                    if !startedClimbing {
                        startedClimbing = true
                    }
                    animateDown()
                }
            } else if isJumping {
                animateJumping()
            }
            if hasHammer {
                animateHammer()
            }
            speedCounter = 0
        }
        speedCounter += 1
    }
    
    func animateRight(){
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            position.x += resolvedInstance.assetDimention / 3.0
            if !hasHammer {
                currentFrame = walking[animateFrame]
            }
            animateFrame += 1
            if animateFrame == 3 {
                animateFrame = 0
                isWalking = false
                if xPos < resolvedInstance.screenDimentionX {
                    xPos += 1
                }
            }
        }
    }
    
    func animateLeft(){
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            position.x -= resolvedInstance.assetDimention / 3.0
            if !hasHammer {
                currentFrame = walking[animateFrame]
            }
            animateFrame += 1
            if animateFrame == 3 {
                animateFrame = 0
                isWalking = false
                if xPos > 0 {
                    xPos -= 1
                }
            }
        }
    }
    
    func animateUp(){
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            position.y -= ladderStep / 4.0
            currentFrame = climbing[animateFrame]
            animateFrame += 1
            if facing == .left {
                facing = .right
            } else {
                facing = .left
            }
            if animateFrame == 4 {
                animateFrame = 0
                isClimbing = false
                if yPos != 0 {
                    yPos -= 1
                    currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                }
                if !isLadderAbove() {
                    currentFrame = ImageResource(name: "JMBack", bundle: .main)
                    isClimbing = false
                    isClimbingUp = false
                    ///Ok so this is just for level 1 Todo other level!
                    if xPos == 17 && yPos == 3  {
                        currentFrame = ImageResource(name: "JM1", bundle: .main)
                        facing = .left
                        NotificationCenter.default.post(name: .notificationLevelComplete, object: nil)
                    }
                }
            }
        }
    }
    
    func animateDown() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            position.y += ladderStep / 4.0
            currentFrame = climbing[animateFrame]
            animateFrame += 1
            if facing == .left {
                facing = .right
            } else {
                facing = .left
            }
            if animateFrame == 4 {
                animateFrame = 0
                isClimbing = false
                if yPos < resolvedInstance.screenDimentionY - 1 {
                    yPos += 1
                    currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                }
                if !isLadderBelow() {
                    currentFrame = ImageResource(name: "JMBack", bundle: .main)
                    isClimbing = false
                    isClimbingDown = false
                }
            }
        }
    }
    
    func animateHammer(){
        guard !isJumping else { return }
        if isWalking {
            currentFrame = hammerWalking[animateHammerFrame]
        } else {
            currentFrame = hammer1[animateHammerFrame]
        }
        frameSize = hammerFrameSize
        animateHammerFrame += 1
        if animateHammerFrame == 16 {
            animateHammerFrame = 0
        }
    }
    
    func move() {
        if !isWalking && !isJumping {
            if isWalkingRight {
                walkRight()
            } else if isWalkingLeft {
                walkLeft()
            }
        }
        if !isClimbing {
            if isClimbingUp {
                climbUp()
            } else if isClimbingDown {
                climbDown()
            }
        }
    }
    
    func walkRight() {
        guard canMoveRight() else {
            isWalking = false
            isWalkingRight = false
            return
        }
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            isWalking = true
            facing = .right
            animateRight()
            currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
            if currentHeightOffset != resolvedInstance.screenData[yPos][xPos+1].assetOffset {
                if currentHeightOffset > resolvedInstance.screenData[yPos][xPos+1].assetOffset {
                    position.y += resolvedInstance.assetOffset
                } else {
                    position.y -= resolvedInstance.assetOffset
                }
            }
        }
    }
    
    func walkLeft() {
        guard canMoveLeft() else {
            isWalking = false
            isWalkingLeft = false
            return
        }
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            isWalking = true
            facing = .left
            animateLeft()
            currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
            if currentHeightOffset != resolvedInstance.screenData[yPos][xPos-1].assetOffset {
                if currentHeightOffset > resolvedInstance.screenData[yPos][xPos-1].assetOffset {
                    position.y += resolvedInstance.assetOffset
                } else {
                    position.y -= resolvedInstance.assetOffset
                }
            }
        }
    }
    
    func climbUp() {
        isClimbing = true
        animateUp()
    }
    
    func climbDown() {
        isClimbing = true
        animateDown()
    }
    
    func jump() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            var jumpOffset = 0.0
            isWalking = false
            isJumpingLeft = isWalkingLeft
            isJumpingRight = isWalkingRight
            let pointA = position
            var pointB = CGPoint()
            // todo jump distance should be asset dimention * 2
            var points = [CGPoint]()
            if isJumpingLeft {
//                if animateFrame > 0 {
//                    jumpOffset = (3.0 - Double(animateFrame)) * (resolvedInstance.assetDimention / 3.0)
//                    pointB = calcPositionFromScreen(xPos: xPos - 3,yPos: yPos,frameSize: frameSize)
//                    pointB.x += jumpOffset
//                } else {
//                    pointB = calcPositionFromScreen(xPos: xPos - 2,yPos: yPos,frameSize: frameSize)
//                }
                pointB = calcPositionFromScreen(xPos: xPos - 2,yPos: yPos,frameSize: frameSize)
                pointB.x = pointA.x - 2 * resolvedInstance.assetDimention
                points = generateParabolicPoints(from: pointA, to: pointB,steps: 12, angleInDegrees: -65)
            } else {
//                if animateFrame > 0 {
//                    jumpOffset = (3.0 - Double(animateFrame)) * (resolvedInstance.assetDimention / 3.0)
//                    pointB = calcPositionFromScreen(xPos: xPos + 3,yPos: yPos,frameSize: frameSize)
//                    pointB.x -= jumpOffset
//                } else {
//                    pointB = calcPositionFromScreen(xPos: xPos + 2,yPos: yPos,frameSize: frameSize)
//                }
                pointB = calcPositionFromScreen(xPos: xPos + 2,yPos: yPos,frameSize: frameSize)
                pointB.x = pointA.x + 2 * resolvedInstance.assetDimention

                points = generateParabolicPoints(from: pointA, to: pointB,steps: 12, angleInDegrees: 65)
            }
            print("Jump animateFrame \(animateFrame) offset \(jumpOffset)")
            points[12] = pointB
            print("Jump Distance = \(pointB.x - pointA.x)")
            jumpingPoints = points
        }
        if let resolvedInstance: SoundFX = ServiceLocator.shared.resolve() {
            resolvedInstance.jumpSound()
        }
    }
    
    func animateJumping() {
        currentFrame = ImageResource(name: "JM2", bundle: .main)
        if isJumpingUp {
            position.y = jumpingPoints[jumpingFrame].y
        } else {
            position = jumpingPoints[jumpingFrame]
        }
        jumpingFrame += 1
        if jumpingFrame == jumpingPoints.count {
            jumpingFrame = 0
            jumpingPoints.removeAll()
            if isJumpingLeft {
                xPos -= 2
                isJumpingLeft = false
                isWalking = true
            } else if isJumpingRight {
                xPos += 2
                isJumpingRight = false
                isWalking = true
            }
            isJumping = false
            isJumpingUp = false
            if hasHammer {
                frameSize = hammerFrameSize
                currentFrame = ImageResource(name: "JMHam1", bundle: .main)
                setPosition()
            } else {
                currentFrame = ImageResource(name: "JM1", bundle: .main)
                
            }
//            setPosition()
        }
    }
    
    
    func canJump()-> Bool {
        if jumpingPoints.isEmpty && !hasHammer { return true }
        return false
    }
    
    func canMoveLeft() -> Bool {
        guard xPos > 0 else {
            return false
        }
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            if resolvedInstance.screenData[yPos][xPos - 1].assetType != .blank {
                return true
            }
        }
        return false
    }
    
    func canMoveRight() -> Bool {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            guard xPos < resolvedInstance.screenDimentionX - 2 else {
                return false
            }
            if resolvedInstance.screenData[yPos][xPos + 1].assetType != .blank {
                return true
            }
        }
        return false
    }
    
    func canClimbLadder() -> Bool {
        if hasHammer || isJumping { return false }
        guard isLadderAbove() && !isClimbing else {
            return false
        }
        return true
    }
    
    func canDecendLadder() -> Bool {
        if hasHammer || isJumping { return false }
        guard isLadderBelow() && !isClimbing else {
            return false
        }
        return true
    }
    
    func removeHammer(){
        hasHammer = false
        frameSize = normalFrameSize
        currentFrame = ImageResource(name: "JM1", bundle: .main)
        position = calcPositionFromScreen()
        self.objectWillChange.send()
    }
}
