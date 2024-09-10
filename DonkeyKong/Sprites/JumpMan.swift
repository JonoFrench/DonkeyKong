//
//  JumpMan.swift
//  DonkeyKong
//
//  Created by Jonathan French on 13.08.24.
//

import Foundation
import SwiftUI

enum JMState {
    case still,walking,climbingUp,climbingDown,hammer,dead, falling
}
enum JMDirection {
    case left,right
}

//struct AroundPosition {
//    var standingOn: AssetType = .blank
//    var below: AssetType = .blank
//    var left: AssetType = .blank
//    var right: AssetType = .blank
//    var above: AssetType = .blank
//    var xPosition: Int = 0
//    var yPosition: Int = 0
//    var position: CGPoint = CGPoint()
//    var xOffset: Double = 0.0
//    var yOffset: Double = 0.0
//    var heightOffset: Double = 0.0
//
//    mutating func setPosition(position:CGPoint) {
//        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
//
//            let actualxWidth = Double(resolvedInstance.gameSize.width / (Double(resolvedInstance.screenDimensionX - 1)))
//
//            xPosition = Int((position.x - (resolvedInstance.assetDimension / 2)) / resolvedInstance.assetDimension)
//
//            yPosition = 2 + Int((position.y - 80) / resolvedInstance.assetDimension)
//
//            //            heightOffset = resolvedInstance.screenData[yPosition][xPosition].assetOffset
//
////            print("Jumpman calculated position:\(position) setPosition X:\(xPosition) Y:\(yPosition) heightOffset:\(heightOffset)")
//
//        }
//    }
//}

final class JumpMan:SwiftUISprite,Moveable,Animatable, ObservableObject {
    static var animateFrames: Int = 0
    static var speed: Int = AppConstant.jumpmanSpeed
    var speedCounter: Int = 0
    var animateCounter: Int = 0
    var isWalking = false
    var wasWalking = false
    var isfalling = false
    var fallingCount = 0
    var isClimbing = false
    var isClimbingUp = false
    var isClimbingDown = false
    var startedClimbing = false
    //    var aroundPosition:AroundPosition = AroundPosition()
    
    //    override var position: CGPoint {
    //        didSet {
    //            aroundPosition.setPosition(position: position)
    //            //            if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
    //            //                print("Jumpman Position \(position) X\(xPos) Y \(yPos) gridOffset \(gridOffsetX) ")
    //            //                print("Jumpman height offset \(currentHeightOffset) actual \(currentHeightOffset * resolvedInstance.assetDimensionStep)")
    //            //                print("Jumpman on \(resolvedInstance.screenData[yPos][xPos].assetType)")
    //            //                print("Jumpman above \(resolvedInstance.screenData[yPos-1][xPos].assetType)")
    //            //            }
    //        }
    //    }
    
    var isJumping:Bool {
        didSet {
            if isJumping {
                print("Control didSet Jumping")
                jump()
            }
        }
    }
    var isJumpingUp:Bool {
        didSet {
            isJumping = isJumpingUp
        }
    }
    var jumpingUpPoints = [CGPoint]()
    var jumpingPoints = [CGPoint]()
    var jumpStartPos = CGPoint()
    @Published
    var hasHammer = false
#if os(iOS)
    var hammerFrameSize: CGSize = CGSize(width: 64, height:  64)
    var normalFrameSize: CGSize = CGSize(width: 32, height:  32)
#elseif os(tvOS)
    var hammerFrameSize: CGSize = CGSize(width: 128, height:  128)
    var normalFrameSize: CGSize = CGSize(width: 64, height:  64)
#endif
    var animateFrame = 0
    var jumpingFrame = 0
    var conveyorFrame = 0
    var moveDistanceX = 0.0
    var moveDataX = 0
    var animateHammerFrame = 0
    @Published
    var facing:JMDirection = .right
    var onLiftUp = false
    var onLiftDown = false
    var standingFrame = ImageResource(name: "JM1", bundle: .main)
    var climbingFrame = ImageResource(name: "JMClimb1", bundle: .main)
    var climbingFrame2 = ImageResource(name: "JMClimb2", bundle: .main)
    var climbingFrame1 = ImageResource(name: "JMClimb3", bundle: .main)
    
    var walking:[ImageResource] = [ImageResource(name: "JM2", bundle: .main),ImageResource(name: "JM2", bundle: .main),ImageResource(name: "JM3", bundle: .main),ImageResource(name: "JM3", bundle: .main),ImageResource(name: "JM1", bundle: .main),ImageResource(name: "JM1", bundle: .main)]
    var climbing:[ImageResource] = [ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb2", bundle: .main),ImageResource(name: "JMClimb2", bundle: .main)]
    var climbing2:[ImageResource] = [ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb2", bundle: .main),ImageResource(name: "JMClimb3", bundle: .main),ImageResource(name: "JMBack", bundle: .main)]
    ///Certain frames i.e when hammer is down can kill barrels and fireblobs.
    var hammerDown:[Bool] = [false,false,false,false,true,true,true,true,false,false,false,false,true,true,true,true]
    var hammer1:[ImageResource] = [ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main)]
    var hammerWalking:[ImageResource] = [ImageResource(name: "JMHam3", bundle: .main),ImageResource(name: "JMHam3", bundle: .main),ImageResource(name: "JMHam3", bundle: .main),ImageResource(name: "JMHam3", bundle: .main),ImageResource(name: "JMHam4", bundle: .main),ImageResource(name: "JMHam4", bundle: .main),ImageResource(name: "JMHam4", bundle: .main),ImageResource(name: "JMHam4", bundle: .main),ImageResource(name: "JMHam5", bundle: .main),ImageResource(name: "JMHam5", bundle: .main),ImageResource(name: "JMHam5", bundle: .main),ImageResource(name: "JMHam5", bundle: .main),ImageResource(name: "JMHam6", bundle: .main),ImageResource(name: "JMHam6", bundle: .main),ImageResource(name: "JMHam6", bundle: .main),ImageResource(name: "JMHam6", bundle: .main)]
    
    override init(xPos: Int, yPos: Int, frameSize: CGSize) {
        isJumping = false
        isJumpingUp = false
        super.init(xPos: xPos, yPos: yPos, frameSize: frameSize)
        currentFrame = standingFrame
        gridOffsetX = 0
        gridOffsetY = 0
    }
    func setupJumpman() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            jumpingUpPoints = generateParabolicPoints(from: CGPoint(x: 0, y: 0), to: CGPoint(x: 2 * resolvedInstance.assetDimension, y: 0),steps: 16, angleInDegrees: 65)
            print("Jumping points \(jumpingPoints)")
            moveDistanceX = resolvedInstance.assetDimensionStep * Double(AppConstant.jumpmanSpeed)
            moveDataX = 8 / AppConstant.jumpmanSpeed
            print("moveDistanceX \(moveDistanceX) moveDataX \(moveDataX)")
        }
    }
    
    func animate(){
        guard isWalking || isClimbing || isJumping || hasHammer || isfalling else {
            return
        }
        if speedCounter == JumpMan.speed {
            if isJumping {
                animateJumping()
            } else if isWalking {
                //                print("Control Walking")
                facing == .right ? animateRight() : animateLeft()
            }
            if isClimbing {
                if isClimbingUp {
                    animateUp()
                } else if isClimbingDown {
                    animateDown()
                }
            }
            if isfalling {
                fall()
            }
            if hasHammer {
                animateHammer()
            }
            speedCounter = 0
            //            calcFromPosition()
            printPosition()

        }
        speedCounter += 1
    }
    
    func printPosition() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            print("Jumpman Position \(position) X\(xPos) Y \(yPos) gridOffset \(gridOffsetX) ")
            print("Jumpman height offset \(currentHeightOffset) actual \(currentHeightOffset * resolvedInstance.assetDimensionStep)")
            print("Jumpman on \(resolvedInstance.screenData[yPos][xPos].assetType)")
            print("Jumpman above \(resolvedInstance.screenData[yPos-1][xPos].assetType)")
            print("Jumpman isWalking \(isWalking) isClimbing \(isClimbing) isJumping \(isJumping) isfalling \(isfalling) isClimbingUp \(isClimbingUp) isClimbingDown \(isClimbingDown) ")
        }
    }
    
    func animateRight(){
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            guard xPos < resolvedInstance.screenDimensionX - 2 else { return }
            position.x += moveDistanceX
            if !hasHammer {
                currentFrame = walking[animateFrame]
            }
            animateFrame += 1
            if animateFrame == 6 {
                animateFrame = 0
            }
            gridOffsetX += 1
            if gridOffsetX == moveDataX {
                if currentHeightOffset != resolvedInstance.screenData[yPos][xPos+1].assetOffset {
                    if currentHeightOffset > resolvedInstance.screenData[yPos][xPos+1].assetOffset {
                        position.y += resolvedInstance.assetDimensionStep
                    } else {
                        position.y -= resolvedInstance.assetDimensionStep
                    }
                }
                
                if xPos < resolvedInstance.screenDimensionX-1 {
                    xPos += 1
                    currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                    gridOffsetX = 0
                }
                /// Level 4 with the Girder plugs
                if resolvedInstance.level == 4 {checkGirderPlug(xOffset: xPos - 1)}
                
            }
            checkStandingOnBlank()
        }
    }
    
    func animateLeft(){
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            guard xPos >= 0 else { return }
            if !(xPos == 0 && gridOffsetX == 0) {
                position.x -= moveDistanceX
                gridOffsetX -= 1
                
                if !hasHammer {
                    currentFrame = walking[animateFrame]
                }
                animateFrame += 1
                if animateFrame == 6 {
                    animateFrame = 0
                }
            }
            if gridOffsetX == -1 {
                if xPos > 0 {
                    if currentHeightOffset != resolvedInstance.screenData[yPos][xPos-1].assetOffset {
                        if currentHeightOffset > resolvedInstance.screenData[yPos][xPos-1].assetOffset {
                            position.y += resolvedInstance.assetDimensionStep
                        } else {
                            position.y -= resolvedInstance.assetDimensionStep
                        }
                    }
                    xPos -= 1
                    currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                    gridOffsetX = moveDataX - 1
                }
                
                /// Level 4 with the Girder plugs
                if resolvedInstance.level == 4 {checkGirderPlug(xOffset: xPos + 1)}
            }
            checkStandingOnBlank()
        }
    }
    
    func checkStandingOnBlank() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            /// On empty space, but just in the middle!
            if resolvedInstance.screenData[yPos][xPos].assetBlank() && gridOffsetX == 1 {
                isfalling = true
                isWalking = false
            }
        }
    }
    
    func checkGirderPlug(xOffset:Int) {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            if resolvedInstance.screenData[yPos][xOffset].assetType == .girderPlug {
                resolvedInstance.screenData[yPos][xOffset].assetType = .blank
                NotificationCenter.default.post(name: .notificationGirderPlug, object: nil)
            }
        }
    }
    
    func fall() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            let speedAdjust = 2
            onLiftUp = false
            onLiftDown = false
            position.y += resolvedInstance.assetDimensionStep * Double(speedAdjust)
            animateFrame += 1
            if animateFrame == moveDataX / speedAdjust {
                fallingCount += 1
                animateFrame = 0
                if yPos < resolvedInstance.screenDimensionY - 1 {
                    yPos += 1
                    currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                }
                if resolvedInstance.screenData[yPos][xPos].assetBlank() {
                    isfalling = true
                    isWalking = false
                } else {
                    isfalling = false
                    _ = checkOnLift()
                    setPosition()
                }
            }
        }
    }
    
    func decendStart(){
        adjustClimbing()
        animateFrame = 0
        calculateLadderHeightDown()
        isClimbing = true
        isClimbingDown = true
        animateDown()
    }
    
    func asendStart(){
        adjustClimbing()
        animateFrame = 0
        calculateLadderHeightUp()
        isClimbing = true
        isClimbingUp = true
        animateUp()
    }
    /// We can climb or desend ladders even if we're one step away left/right.
    /// Gives a bit more flexibility to move when playng the game
    /// If this is so we adjust JumpMan to be exactly on the ladder when on it.
    func adjustClimbing() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            if ladderAdjustL {
                xPos += 1
                gridOffsetX = 0
                position.x += resolvedInstance.assetDimensionStep
                ladderAdjustL = false
            } else if ladderAdjustR {
                gridOffsetX = 0
                position.x -= resolvedInstance.assetDimensionStep
                ladderAdjustR = false
            }
        }
    }
    
    func animateClimb() {
        if ladderPosition % 2 == 0 {
            facing = facing == .left ? .right : .left
        }
        if ladderPosition == ladderRungs || ladderPosition == ladderRungs - 1 {
            currentFrame = climbingFrame1
        } else if ladderPosition == ladderRungs - 2 || ladderPosition == ladderRungs - 3 {
            currentFrame = climbingFrame2
        } else {
            currentFrame = climbingFrame
        }
    }
    
    func animateUp(){
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            if yPos < 15 {
                if resolvedInstance.screenData[yPos-1][xPos].assetType == .blankLadder {
                    if let resolvedLadders: Ladders = ServiceLocator.shared.resolve() {
                        if resolvedLadders.leftLadder.state == .closed {
                            return
                        }
                    }
                }
            }
            position.y -= ladderStep / 4.0
            ladderPosition += 1
            animateClimb()
            if ladderPosition % 4 == 0 {
                if yPos != 0 {
                    yPos -= 1
                }
            }
            if ladderPosition == ladderRungs {
                currentFrame = ImageResource(name: "JMBack", bundle: .main)
                isClimbing = false
                isClimbingUp = false
                currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                ///Ok so this is just for level 1,2,3 4 is handled elsewhere with the girder plugs
                ///
                if xPos == 17 && yPos == 3  {
                    currentFrame = ImageResource(name: "JM1", bundle: .main)
                    facing = .left
                    NotificationCenter.default.post(name: .notificationLevelComplete, object: nil)
                }
                
            }
        }
    }
    
    func animateDown() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            position.y += ladderStep / 4.0
            ladderPosition -= 1
            animateClimb()
            
            if ladderPosition % 4 == 0 {
                if yPos < resolvedInstance.screenDimensionY - 1 {
                    yPos += 1
                }
            }
            if ladderPosition == 0 {
                currentFrame = ImageResource(name: "JMBack", bundle: .main)
                isClimbing = false
                isClimbingDown = false
                currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
            }
        }
    }
    
    func animateHammer(){
        guard !isJumping else { return }
        currentFrame = isWalking ? hammerWalking[animateHammerFrame] : hammer1[animateHammerFrame]
        frameSize = hammerFrameSize
        animateHammerFrame += 1
        if animateHammerFrame == 16 {
            animateHammerFrame = 0
        }
    }
    
    func move() {
    }
    
    func stop() {
        if isWalking {
            if !hasHammer {
                currentFrame = standingFrame
            }
            isWalking = false
        }
        wasWalking = false
        isClimbing = false
    }
    
    func jump() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            var jumpOffset = 0.0
            var jumpDifference = 0.0
            var jumpingTo = CGPoint()
            isWalking = false
            onLiftUp = false
            onLiftDown = false
            jumpStartPos = position
            if !isJumpingUp {
                if facing == .right {
                    jumpingTo = position
                    jumpingTo.x += resolvedInstance.assetDimension * 2
                    if xPos < resolvedInstance.screenDimensionX - 3 {
                        jumpOffset = getOffsetForPosition(xPos: xPos + 2, yPos: yPos)
                    } else {
                        jumpOffset = currentHeightOffset
                    }
                    if jumpOffset != currentHeightOffset {
                        if jumpOffset > currentHeightOffset {
                            jumpDifference = jumpOffset - currentHeightOffset
                            //                            print("Jumpman right up jumpDifference \(jumpDifference)")
                            jumpingTo.y -= jumpDifference * resolvedInstance.assetDimensionStep
                        } else {
                            jumpDifference = currentHeightOffset - jumpOffset
                            //                            print("Jumpman right down jumpDifference \(jumpDifference)")
                            jumpingTo.y += jumpDifference * resolvedInstance.assetDimensionStep
                        }
                    }
                    jumpingPoints = generateParabolicPoints(from: position, to: jumpingTo,steps: 16, angleInDegrees: 65)
                } else {
                    jumpingTo = position
                    jumpingTo.x -= resolvedInstance.assetDimension * 2
                    if xPos > 1 {
                        jumpOffset = getOffsetForPosition(xPos: xPos - 2, yPos: yPos)
                    } else {
                        jumpOffset = currentHeightOffset
                    }
                    if jumpOffset != currentHeightOffset {
                        if jumpOffset > currentHeightOffset {
                            jumpDifference = jumpOffset - currentHeightOffset
                            //                            print("Jumpman left up jumpDifference \(jumpDifference)")
                            jumpingTo.y -= jumpDifference * resolvedInstance.assetDimensionStep
                        } else {
                            jumpDifference = currentHeightOffset - jumpOffset
                            //                            print("Jumpman left down jumpDifference \(jumpDifference)")
                            jumpingTo.y += jumpDifference * resolvedInstance.assetDimensionStep
                        }
                    }
                    jumpingPoints = generateParabolicPoints(from: position, to: jumpingTo,steps: 16, angleInDegrees: -65)
                }
                jumpingPoints[16] = jumpingTo
            }
        }
        if let resolvedInstance: SoundFX = ServiceLocator.shared.resolve() {
            resolvedInstance.jumpSound()
        }
    }
    
    func animateJumping() {
        currentFrame = ImageResource(name: "JM2", bundle: .main)
        if isJumpingUp {
            position.y = jumpStartPos.y + jumpingUpPoints[jumpingFrame].y
        } else {
            position = jumpingPoints[jumpingFrame]
            if position.x < 6.77 {
                position.x = 6.77
                xPos = 0
            } else if position.x > 386.22 {
                position.x = 386.33
                xPos = 27
            }
            
        }
        calcFromPosition()
        jumpingFrame += 1
        if !isJumpingUp {
            /// Going down here. See if we land on anything
            if jumpingFrame >= jumpingPoints.count / 2 {
                print("Lift jump check")
                if checkOnLift() {
                    finishJump()
                }
            }
            
            if jumpingFrame == jumpingPoints.count {
                jumpingFrame = 0
                _ = checkOnLift()
                finishJump()
            }
        } else {
            if jumpingFrame == jumpingUpPoints.count {
                jumpingFrame = 0
                finishJump()
            }
        }
    }
    
    func finishJump() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            if facing == .left && !isJumpingUp  {
                xPos -= 2
                currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                isWalking = wasWalking
            } else if facing == .right && !isJumpingUp {
                xPos += 2
                currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                isWalking = wasWalking
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
            if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
                if resolvedInstance.screenData[yPos][xPos].assetBlank() && gridOffsetX == 1 {
                    isfalling = true
                }
            }
        }
    }
    
    func canJump()-> Bool {
        if !hasHammer && !isfalling && !isClimbing && !isJumping { return true }
        return false
    }
    
    func canMoveLeft() -> Bool {
        guard xPos >= 0 && !isfalling else {
            return false
        }
        return true
    }
    
    func canMoveRight() -> Bool {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            guard xPos < resolvedInstance.screenDimensionX - 2 && !isfalling else {
                return false
            }
        }
        return true
    }
    
    func canClimbLadder() -> Bool {
        if hasHammer || isJumping { return false }
        if isLadderAbove() {
            if ladderAdjustL { return true}
            if gridOffsetX <= 1 {
                if gridOffsetX == 1 {
                    ladderAdjustR = true
                }
                return true
            }
        }
        return false
    }
    
    func canDecendLadder() -> Bool {
        if hasHammer || isJumping { return false }
        if isLadderBelow() {
            if ladderAdjustL { return true}
            if gridOffsetX <= 1 {
                if gridOffsetX == 1 {
                    ladderAdjustR = true
                }
                return true
            }
        }
        return false
    }
    
    func removeHammer(){
        hasHammer = false
        frameSize = normalFrameSize
        currentFrame = ImageResource(name: "JM1", bundle: .main)
        gridOffsetX = 0
        position = calcPositionFromScreen()
    }
    
    func checkOnLift() -> Bool {
        guard yPos < 26 else {return false}
        // On a lift?
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            //            if resolvedInstance.screenData[yPos][xPos].assetType == .liftGirder || resolvedInstance.screenData[yPos+1][xPos].assetType == .liftGirder {
            if calcJumpingOnLift() {
                if xPos == 4 || xPos == 5 {
                    onLiftUp = true
                    print("On lift up")
                    return true
                } else {
                    print("On lift down")
                    onLiftDown = true
                    return true
                }
            }
        }
        return false
    }
    /// Level 2 Conveyor belts!
    ///
    func conveyor(direction:ConveyorDirection) {
        conveyorFrame += 1
        if conveyorFrame == 4 {
            conveyorFrame = 0
            if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
                
                if yPos == 22 {
                    if resolvedInstance.screenData[yPos][xPos].assetType == .conveyor {
                        if direction == .left {
                            guard xPos >= 0 else { return }
                            position.x -= moveDistanceX
                            gridOffsetX -= 1
                            if gridOffsetX == -1 {
                                xPos -= 1
                                gridOffsetX = moveDataX - 1
                            }
                        } else if direction == .right {
                            guard xPos < resolvedInstance.screenDimensionX - 2 else { return }
                            position.x += moveDistanceX
                            gridOffsetX += 1
                            if gridOffsetX == moveDataX {
                                xPos += 1
                                gridOffsetX = 0
                            }
                        }
                    }
                } else if yPos == 12 {
                    if xPos < 16 {
                        position.x += moveDistanceX
                        gridOffsetX += 1
                        if gridOffsetX == moveDataX {
                            xPos += 1
                            gridOffsetX = 0
                        }
                        
                    } else {
                        //                            guard xPos >= 18 else { return }
                        position.x -= moveDistanceX
                        gridOffsetX -= 1
                        if gridOffsetX == -1 {
                            xPos -= 1
                            gridOffsetX = moveDataX - 1
                        }
                        
                    }
                }
                else if yPos == 7 {
                    
                }
                printPosition()
            }
        }
        
    }
}
