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

final class JumpMan:SwiftUISprite,Moveable,Animatable, ObservableObject {
    static var animateFrames: Int = 0
    static var speed: Int = GameConstants.jumpmanSpeed
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
    var isJumping:Bool {
        didSet {
            if isJumping {
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
    let jumpDistance = 3
    var willLandOnLift = false
    @Published
    var hasHammer = false
#if os(iOS)
    var hammerFrameSize: CGSize = CGSize(width: 64, height:  64)
    var deadFrameSize: CGSize = CGSize(width: 40, height:  40)
    var normalFrameSize: CGSize = CGSize(width: 32, height:  32)
#elseif os(tvOS)
    var hammerFrameSize: CGSize = CGSize(width: 128, height:  128)
    var deadFrameSize: CGSize = CGSize(width: 80, height:  80)
    var normalFrameSize: CGSize = CGSize(width: 64, height:  64)
#endif
    var animateFrame = 0
    var fallingFrame = 0
    var jumpingFrame = 0
    var conveyorFrame = 0
    var moveDistanceX = 0.0
    var moveDataX = 0
    var jumpYAdjust = 0
    var animateHammerFrame = 0
    @Published
    var facing:JMDirection = .right
    var onLiftUp = false
    var onLiftDown = false
    var isDying = false
    var isDead = false
    var standingFrame = ImageResource(name: "JM1", bundle: .main)
    var deadFrame = ImageResource(name: "JMDead1", bundle: .main)
    var climbingFrame = ImageResource(name: "JMClimb1", bundle: .main)
    var climbingFrame2 = ImageResource(name: "JMClimb2", bundle: .main)
    var climbingFrame1 = ImageResource(name: "JMClimb3", bundle: .main)
    var dieing:[ImageResource] = [ImageResource(name: "JMDead1", bundle: .main),ImageResource(name: "JMDead2", bundle: .main),ImageResource(name: "JMDead3", bundle: .main),ImageResource(name: "JMDead4", bundle: .main)]

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
            moveDistanceX = resolvedInstance.assetDimensionStep * Double(GameConstants.jumpmanSpeed)
            moveDataX = 8 / GameConstants.jumpmanSpeed
            print("moveDistanceX \(moveDistanceX) moveDataX \(moveDataX)")
        }
    }
    
    func reset() {
        currentFrame = standingFrame
        frameSize = normalFrameSize
        gridOffsetX = 0
        gridOffsetY = 0
        isJumping = false
        isJumpingUp = false
        facing = .right
        onLiftUp = false
        onLiftDown = false
        animateFrame = 0
        fallingFrame = 0
        jumpingFrame = 0
        conveyorFrame = 0
        jumpYAdjust = 0
        animateHammerFrame = 0
        hasHammer = false
        willLandOnLift = false
        isDead = false
        isDying = false
    }
    
    func animate(){
        guard isWalking || isClimbing || isJumping || hasHammer || isfalling || isDying else {
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
            if isDying {
                animateDead()
            }
            
            speedCounter = 0
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
                if resolvedInstance.level == GameConstants.GirderPlugs {checkGirderPlug(xOffset: xPos - 1)}
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
                if resolvedInstance.level == GameConstants.GirderPlugs {checkGirderPlug(xOffset: xPos + 1)}
            }
            checkStandingOnBlank()
        }
    }
    
    func checkStandingOnBlank() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            /// On empty space, but just in the middle!
            if resolvedInstance.screenData[yPos][xPos].assetBlank() && gridOffsetX == 1 {
                fallingCount = 0
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
            position.y += resolvedInstance.assetDimensionStep * Double(speedAdjust)
            fallingFrame += 1
            if fallingFrame == 4 {
                fallingCount += 1
                fallingFrame = 0
                if yPos < resolvedInstance.screenDimensionY - 1 {
                    yPos += 1
                    currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                }
                if resolvedInstance.screenData[yPos][xPos].assetBlank() || resolvedInstance.screenData[yPos][xPos].assetType == .liftGirder {
                    isfalling = true
                    isWalking = false
                    fallingFrame = 0
                } else {
                    isfalling = false
                    if fallingCount > 2 {
                        dead()
                    }
                }
                print("Jumpman falling yPos \(yPos) falling count \(fallingCount)")
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
                    currentFrame = standingFrame
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
            resolvedInstance.farCount = 0
            var jumpOffset = 0.0
            var jumpDifference = 0.0
            var jumpingTo = CGPoint()
            isWalking = false
            onLiftUp = false
            onLiftDown = false
            willLandOnLift = false
            jumpYAdjust = 0
            jumpStartPos = position
            if !isJumpingUp {
                if facing == .right {
                    jumpingTo = position
                    jumpingTo.x += resolvedInstance.assetDimension * CGFloat(jumpDistance) /// Jumping jumpDistance blocks to the right
                    
                    if resolvedInstance.level == GameConstants.Elevators && yPos < 26 {
                        
                        if xPos < 9 {
                            /// Jumping on to lift going up from the right
                            if resolvedInstance.screenData[yPos][xPos+jumpDistance].assetType == .liftGirder {
                                let off = resolvedInstance.screenData[yPos][xPos+jumpDistance].assetOffset
                                print("Lift jumped right on offset \(off)")
                                jumpYAdjust = -1
                                print("Lift jumped right will land ok")
                                jumpingTo.y -= resolvedInstance.assetDimension + ((resolvedInstance.assetDimension / 8) * off)
                                willLandOnLift = true
                            }
                            if resolvedInstance.screenData[yPos+1][xPos+jumpDistance].assetType == .liftGirder {
                                let off = resolvedInstance.screenData[yPos+1][xPos+jumpDistance].assetOffset
                                print("Lift jumped right on coming up offset \(off)")
                                print("Lift jumped right will land ok")
                                jumpingTo.y -= resolvedInstance.assetDimension - ((resolvedInstance.assetDimension / 8) * (8 - off))
                                willLandOnLift = true
                            }
                        } else {
                            /// Jumping on to lift going down from the right
                            if resolvedInstance.screenData[yPos][xPos+jumpDistance].assetType == .liftGirder {
                                let off = resolvedInstance.screenData[yPos][xPos+jumpDistance].assetOffset
                                print("Lift going down right jumped on offset \(off)")
                                jumpYAdjust = -1
                                jumpingTo.y += resolvedInstance.assetDimension + ((resolvedInstance.assetDimension / 8) * off)
                                willLandOnLift = true
                            }
                            if resolvedInstance.screenData[yPos-1][xPos+jumpDistance].assetType == .liftGirder {
                                let off = resolvedInstance.screenData[yPos-1][xPos+jumpDistance].assetOffset
                                print("Lift going down right jumped on coming down offset \(off)")
                                jumpingTo.y -= resolvedInstance.assetDimension - ((resolvedInstance.assetDimension / 8) * (8 - off))
                                willLandOnLift = true
                            }

                        }
                    }
                    if !willLandOnLift {
                        if resolvedInstance.screenData[yPos][xPos+jumpDistance].assetBlank() {
                            if resolvedInstance.screenData[yPos-1][xPos+jumpDistance].assetType == .girder {
                                jumpYAdjust = -1
                                jumpingTo.y -= resolvedInstance.assetDimension
                            }
                            if resolvedInstance.screenData[yPos+1][xPos+jumpDistance].assetType == .girder {
                                jumpYAdjust = 1
                                jumpingTo.y += resolvedInstance.assetDimension
                            }
                            print ("Jumpman jumping up or down a bit right\(jumpYAdjust)")
                        }
                        if xPos < resolvedInstance.screenDimensionX - 3 {
                            jumpOffset = getOffsetForPosition(xPos: xPos + jumpDistance, yPos: yPos + jumpYAdjust)
                        } else {
                            jumpOffset = currentHeightOffset
                        }
                        if jumpOffset != currentHeightOffset {
                            if jumpOffset > currentHeightOffset {
                                jumpDifference = jumpOffset - currentHeightOffset
                                                            print("Jumpman right up jumpDifference \(jumpDifference)")
                                jumpingTo.y -= jumpDifference * resolvedInstance.assetDimensionStep
                            } else {
                                jumpDifference = currentHeightOffset - jumpOffset
                                                            print("Jumpman right down jumpDifference \(jumpDifference)")
                                jumpingTo.y += jumpDifference * resolvedInstance.assetDimensionStep
                            }
                        }
                    }
                    jumpingPoints = generateParabolicPoints(from: position, to: jumpingTo,steps: 15, angleInDegrees: 65)
                } else {
                    jumpingTo = position
                    jumpingTo.x -= resolvedInstance.assetDimension * CGFloat(jumpDistance)
                    if resolvedInstance.level == GameConstants.Elevators && yPos < 26 {
                        if xPos < 9 {
                            /// Jumping on to lift going up from the left
                            if resolvedInstance.screenData[yPos][xPos-jumpDistance].assetType == .liftGirder {
                                let off = resolvedInstance.screenData[yPos][xPos-jumpDistance].assetOffset
                                print("Lift jumped left on offset \(off)")
                                jumpYAdjust = -1
                                print("Lift jumped left will land ok")
                                jumpingTo.y -= resolvedInstance.assetDimension + ((resolvedInstance.assetDimension / 8) * off)
                                willLandOnLift = true
                            }
                            if resolvedInstance.screenData[yPos+1][xPos-jumpDistance].assetType == .liftGirder {
                                let off = resolvedInstance.screenData[yPos+1][xPos-jumpDistance].assetOffset
                                print("Lift jumped left on coming up offset \(off)")
                                print("Lift jumped left will land ok")
                                jumpingTo.y -= resolvedInstance.assetDimension - ((resolvedInstance.assetDimension / 8) * (8 - off))
                                willLandOnLift = true
                            }
                        } else {
                            /// Jumping on to lift going down from the left
                            if resolvedInstance.screenData[yPos][xPos-jumpDistance].assetType == .liftGirder {
                                let off = resolvedInstance.screenData[yPos][xPos-jumpDistance].assetOffset
                                print("Lift going down left jumped on offset \(off)")
                                jumpYAdjust = -1
                                jumpingTo.y += resolvedInstance.assetDimension + ((resolvedInstance.assetDimension / 8) * off)
                                willLandOnLift = true
                            }
                            if resolvedInstance.screenData[yPos-1][xPos-jumpDistance].assetType == .liftGirder {
                                let off = resolvedInstance.screenData[yPos-1][xPos-jumpDistance].assetOffset
                                print("Lift going down left jumped on coming down offset \(off)")
                                jumpingTo.y -= resolvedInstance.assetDimension - ((resolvedInstance.assetDimension / 8) * (8 - off))
                                willLandOnLift = true
                            }

                        }
                    }
                    if !willLandOnLift {
                        if resolvedInstance.screenData[yPos][xPos-jumpDistance].assetBlank() {
                            if resolvedInstance.screenData[yPos-1][xPos-jumpDistance].assetType == .girder {
                                jumpYAdjust = -1
                                jumpingTo.y -= resolvedInstance.assetDimension
                                print ("Jumpman jumping up a bit left\(jumpYAdjust)")
                            }
                            if resolvedInstance.screenData[yPos+1][xPos-jumpDistance].assetType == .girder {
                                jumpYAdjust = 1
                                jumpingTo.y += resolvedInstance.assetDimension
                                print ("Jumpman jumping down a bit left\(jumpYAdjust)")
                            }
                        }
                        if xPos > 1 {
                            jumpOffset = getOffsetForPosition(xPos: xPos - jumpDistance, yPos: yPos + jumpYAdjust)
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
                        
                    }
                    jumpingPoints = generateParabolicPoints(from: position, to: jumpingTo,steps: 15, angleInDegrees: -65)
                }
                jumpingPoints[15] = jumpingTo
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
            if jumpingFrame == jumpingPoints.count {
                jumpingFrame = 0
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
            print("Lift moved \(resolvedInstance.farCount)")
            if facing == .left && !isJumpingUp  {
                if xPos - jumpDistance < 0 {
                    xPos = 0
                } else {
                    xPos -= jumpDistance
                }
                yPos += jumpYAdjust ///This is going to be + or - so add it!
                currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                isWalking = wasWalking
            } else if facing == .right && !isJumpingUp {
                if xPos + jumpDistance > resolvedInstance.screenDimensionX - 2 {
                    xPos = resolvedInstance.screenDimensionX - 2
                } else {
                    xPos += jumpDistance
                }
                yPos += jumpYAdjust
                currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                isWalking = wasWalking
            }
            if willLandOnLift {
                if xPos == 4 || xPos == 5 {
                    onLiftUp = true
                    print("On Lift jumped lift up")
                } else {
                    print("On Lift jumped lift down")
                    onLiftDown = true
                }
                willLandOnLift = false
            }
            printPosition()

            isJumping = false
            isJumpingUp = false
            if hasHammer {
                frameSize = hammerFrameSize
                currentFrame = ImageResource(name: "JMHam1", bundle: .main)
                setPosition()
            } else {
                currentFrame = standingFrame
            }
            if !onLiftUp && !onLiftDown {
                if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
                    if resolvedInstance.screenData[yPos][xPos].assetType == .LiftPoleL || resolvedInstance.screenData[yPos][xPos].assetType == .LiftPoleR || resolvedInstance.screenData[yPos][xPos].assetType == .ladder {
                        fallingFrame = 0
                        isfalling = true
                    } else if resolvedInstance.screenData[yPos][xPos].assetBlank() {
                        fallingFrame = 0
                        isfalling = true
                    }
                }
            } else {
                if resolvedInstance.screenData[yPos][xPos].assetBlank() {
                    fallingFrame = 0
                    isfalling = true
                }
            }
            print("Finished Jump X:\(xPos) y:\(yPos)")
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
        currentFrame = standingFrame
        gridOffsetX = 0
        position = calcPositionFromScreen()
    }
    
    func dead(){
        isWalking = false
        isClimbing = false
        isJumping = false
        hasHammer = false
        isfalling = false
        currentFrame = deadFrame
        frameSize = deadFrameSize
        animateCounter = 0
        currentAnimationFrame = 0
        isDying = true
        if let resolvedInstance: SoundFX = ServiceLocator.shared.resolve() {
            resolvedInstance.deathSound()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [self] in
            isDying = false
            isDead = true
            NotificationCenter.default.post(name: .notificationJumpManDead, object: nil)
        }
    }
    func animateDead() {
        animateCounter += 1
        if animateCounter == JumpMan.speed * 2 {
            currentFrame = dieing[currentAnimationFrame]
            currentAnimationFrame += 1
            if currentAnimationFrame == dieing.count {
                currentAnimationFrame = 0
            }
            animateCounter = 0
        }

    }
    
    /// Level 2 Conveyor belts!
    ///
    func conveyor(direction:ConveyorDirection) {
        guard !isClimbing else {return}
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
