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

enum JoyPad {
    case left,right,up,down,stop
}

struct GameConstants {
    static let Barrels = 1
    static let PieFactory = 2
    static let Elevators = 3
    static let GirderPlugs = 4
    
    static let pieSpeed = 4
    static let springSpeed = 1
    static let barrelSpeed = 2
    static let fireBlobSpeed = 5
    static let jumpmanSpeed = 2
    static let kongSpeed = 4
    static let elevatorSpeed = 4
    
#if os(iOS)
    static var startText = "PRESS JUMP TO START"
    static var paulineSize = CGSize(width: 63, height: 36)
    static var kongSize = CGSize(width: 60, height: 60)
    static var jumpmanSize = CGSize(width: 32, height: 32)
    static var flamesSize = CGSize(width: 24, height: 24)
    static var pointsSize = CGSize(width: 32, height: 32)
    static var explodeSize = CGSize(width: 32, height: 32)
#elseif os(tvOS)
    static var startText = "PRESS A TO START"
    static var paulineSize = CGSize(width: 126, height: 72)
    static var kongSize = CGSize(width: 120, height: 120)
    static var jumpmanSize = CGSize(width: 64, height: 64)
    static var flamesSize = CGSize(width: 48, height: 48)
    static var pointsSize = CGSize(width: 64, height: 64)
    static var explodeSize = CGSize(width: 64, height: 64)
#endif
}

class GameManager: ObservableObject {
    let soundFX:SoundFX = SoundFX()
    let hiScores:DonkeyKongHighScores = DonkeyKongHighScores()
    @Published
    var gameScreen:ScreenData = ScreenData()
    @Published
    var gameState:GameState = .intro
    @Published
    var lives = 3
    var score = 0
    @Published
    var bonus = 5000
    ///Sprites of sorts....
    @ObservedObject
    var jumpMan:JumpMan = JumpMan(xPos: 0, yPos: 0, frameSize: GameConstants.jumpmanSize)
    @ObservedObject
    var kong:Kong = Kong(xPos: 0, yPos: 0, frameSize: GameConstants.kongSize)
    var pauline:Pauline = Pauline(xPos: 0, yPos: 0, frameSize: GameConstants.paulineSize)
    let heartBeat = 0.6
    var flames:Flames = Flames(xPos: 0, yPos: 0, frameSize: GameConstants.flamesSize)
    var collectibles:[Collectible] = []
    var elevatorsArray:ElevatorArray = ElevatorArray()
    var lift:Lift = Lift()
    
    @ObservedObject
    var barrelArray:BarrelArray = BarrelArray()
    @ObservedObject
    var fireBlobArray:FireBlobArray = FireBlobArray()
    @ObservedObject
    var springArray:SpringArray = SpringArray()
    @ObservedObject
    var pieArray:PieArray = PieArray()
    
    let heart = Collectible(type: .heart, xPos: 15, yPos: 2)
    var explosion:Explode = Explode(xPos: 0, yPos: 0, frameSize: GameConstants.explodeSize)
    var pointsShow:Points = Points(xPos: 0, yPos: 0, frameSize: GameConstants.pointsSize)
    @ObservedObject
    var conveyorArray:ConveyorArray = ConveyorArray()
    @ObservedObject
    var loftLadders = Ladders()
    var moveDirection: JoyPad {
        didSet {
            if moveDirection != oldValue {
                handleJoyPad()
            }
        }
    }
    /// So we can turn off Jumpman collisions to test
    var turnOffCollisions = false
    var checkCounter:Int = 0 {
        didSet {
            if checkCounter > 4 {
                checkCounter = 0
            }
        }
    }
    
    init() {
        moveDirection = .stop
        /// Share these instances so they are available from the Sprites
        ServiceLocator.shared.register(service: gameScreen)
        ServiceLocator.shared.register(service: fireBlobArray)
        ServiceLocator.shared.register(service: barrelArray)
        ServiceLocator.shared.register(service: elevatorsArray)
        ServiceLocator.shared.register(service: loftLadders)
        ServiceLocator.shared.register(service: soundFX)
        ServiceLocator.shared.register(service: jumpMan)
        
        ///Here we go, lets have a nice DisplayLink to update our model with the screen refresh.
        let displayLink:CADisplayLink = CADisplayLink(target: self, selector: #selector(refreshModel))
        displayLink.add(to: .main, forMode:.common)
        notificationObservers()
    }
    
    func startGame() {
        gameScreen.assetDimension = gameScreen.gameSize.width / Double(gameScreen.screenDimensionX - 1)
        gameScreen.assetDimensionStep = gameScreen.assetDimension / 8.0
        gameScreen.verticalOffset =  -50.0 //(gameSize.height - (assetDimention * 25.0))
        lives = 3
        score = 0
        jumpMan.setupJumpman()
//        turnOffCollisions = true
        if gameScreen.level == 1 {
            setKongIntro()   /// If we don't want the intro....
        } else {
            startPlaying()      /// swap these 2 around.
        }
    }
    func addPoints(value:Int,position:CGPoint) {
        gameScreen.hasPoints = true
        pointsShow.pointsText = "\(value)"
        score += value
        pointsShow.position = position
        pointsShow.animateCounter = 0
    }
    
    func handleJoyPad() {
        switch moveDirection {
        case .down:
            if gameState == .playing {
                if jumpMan.isClimbingDown || jumpMan.isClimbingUp {
                    jumpMan.isClimbing = true
                    jumpMan.isClimbingDown = true
                    jumpMan.isClimbingUp = false
                } else if jumpMan.canDecendLadder() {
                    jumpMan.decendStart()
                }
            }
        case .left:
            if gameState == .playing {
                if jumpMan.canMoveLeft() {
                    jumpMan.animateFrame = 0
                    jumpMan.facing = .left
                    jumpMan.isWalking = true
                    jumpMan.wasWalking = true
                }
            }
        case .right:
            if gameState == .playing {
                if jumpMan.canMoveRight() {
                    jumpMan.animateFrame = 0
                    jumpMan.isWalking = true
                    jumpMan.facing = .right
                    jumpMan.wasWalking = true
                }
            }
        case .up:
            if gameState == .playing {
                if jumpMan.isClimbingUp || jumpMan.isClimbingDown {
                    jumpMan.isClimbing = true
                    jumpMan.isClimbingDown = false
                    jumpMan.isClimbingUp = true
                } else if jumpMan.canClimbLadder() {
                    jumpMan.asendStart()
                }
            }
        case.stop:
            jumpMan.stop()
        }
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
        
        if gameState == .playing  && !gameScreen.gameOver {
            if !gameScreen.pause {
                if !gameScreen.levelEnd {
                    jumpMan.animate()
                    if !jumpMan.isDying {
                        if gameScreen.level == GameConstants.Barrels {
                            checkCounter += 1
                            throwBarrel()
                            for barrel in barrelArray.barrels {
                                barrel.animate()
                                barrel.move()
                                if checkCounter == 4 {
                                    checkJumpManHit(barrel: barrel)
                                    checkBarrelHit(barrel: barrel)
                                    checkBarrelJumped(barrel: barrel)
                                }
                            }
                            for fireBlob in fireBlobArray.fireblob {
                                fireBlob.animate()
                                fireBlob.state == .hopping ? fireBlob.hop(state: .moving) : fireBlob.move()
                                if checkCounter == 4 {
                                    checkJumpManHit(fireBlob: fireBlob)
                                    checkFireBlobHit(fireBlob: fireBlob)
                                    checkFireBlobJumped(fireBlob: fireBlob)
                                }
                            }
                        }
                        if gameScreen.level == GameConstants.PieFactory {
                            checkCounter += 1
                            kong.moveSlide()
                            addPies()
                            pieArray.movePies()
                            for pie in pieArray.pies {
                                if checkCounter == 4 {
                                    checkJumpManHit(pie: pie)
                                    checkPieHit(pie: pie)
                                    checkPieJumped(pie: pie)
                                }
                            }
                            conveyorArray.moveConveyors()
                            jumpMan.conveyor(direction: pieArray.direction)
                            for fireBlob in fireBlobArray.fireblob {
                                fireBlob.animate()
                                if fireBlob.state == .moving {
                                    fireBlob.move()
                                } else if fireBlob.state == .sitting {
                                    startMovingFireBlob(fireBlob: fireBlob)
                                } else if fireBlob.state == .hopping {
                                    fireBlob.hop(state: .moving)
                                }
                                if checkCounter == 4 {
                                    checkJumpManHit(fireBlob: fireBlob)
                                    checkFireBlobHit(fireBlob: fireBlob)
                                    checkFireBlobJumped(fireBlob: fireBlob)
                                }
                            }
                            loftLadders.animate()
                            if checkCounter >= 4 { checkCounter = 0}
                        }
                        if gameScreen.level == GameConstants.Elevators {
                            checkCounter += 1
                            throwSpring()
                            for fireBlob in fireBlobArray.fireblob {
                                fireBlob.animate()
                                fireBlob.move()
                                if checkCounter == 4 {
                                    checkJumpManHit(fireBlob: fireBlob)
                                    checkFireBlobHit(fireBlob: fireBlob)
                                    checkFireBlobJumped(fireBlob: fireBlob)
                                }
                            }
                            springArray.move()
                            for spring in springArray.springs {
                                if checkCounter == 4 {
                                    checkJumpManHit(spring: spring)
                                }
                            }
                            lift.move()
                        }
                        if gameScreen.level == GameConstants.GirderPlugs {
                            checkCounter += 1
                            for fireBlob in fireBlobArray.fireblob {
                                fireBlob.animate()
                                fireBlob.move()
                                if checkCounter == 4 {
                                    checkJumpManHit(fireBlob: fireBlob)
                                    checkFireBlobHit(fireBlob: fireBlob)
                                    checkFireBlobJumped(fireBlob: fireBlob)
                                }
                                fireBlob.hasHammer = jumpMan.hasHammer
                            }
                        }
                    }
                } else {
                    if gameScreen.level == GameConstants.GirderPlugs {
                        if kong.state == .dying {
                            kong.animateFinalExit()
                        }
                        if kong.state == .dead {
                            kong.moveFall()
                        }
                    } else {
                        kong.animateExit(level: gameScreen.level)
                    }
                }
            }
            pauline.animate()
            
            if gameScreen.hasFlames {
                flames.animate()
            }
            if collectibles.count > 0 {
                checkCollectibles()
            }
            if gameScreen.hasExplosion {
                explosion.animate()
            }
            if gameScreen.hasPoints {
                pointsShow.animate()
            }
        }
    }
    
    func setKongIntro() {
        gameState = .kongintro
        gameScreen.screenData = KongScreen().getScreenData()
        kong.setPosition(xPos: 16, yPos: 25)
        kong.adjustPosition()
        gameScreen.setLadders()
        pauline.setPosition(xPos: 14, yPos: 3)
        pauline.isShowing = false
        kong.runIntro()
    }
    
    func startPlaying() {
        gameScreen.pause = false
        gameScreen.levelEnd = false
        gameScreen.gameOver = false
        bonus = 4000
        setDataForLevel()
        gameState = .playing
        startBonusCountdown()
        kong.currentFrame = kong.kongFacing
        kong.state = .sitting
        //startHeartBeat()
        if gameScreen.level == GameConstants.Barrels {
            kong.isThrowing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                throwBarrelDown()
            }
        } else if gameScreen.level == GameConstants.PieFactory {
            kong.animateAngry()
            swapConveyorDirection()
        } else if gameScreen.level == GameConstants.Elevators {
            kong.animateAngry()
        } else if gameScreen.level == GameConstants.GirderPlugs {
            kong.animateAngry()
            addLevel4FireBlobs()
        }
    }
    
    func setDataForLevel() {
        collectibles.removeAll()
        barrelArray.barrels.removeAll()
        fireBlobArray.fireblob.removeAll()
        elevatorsArray.elevators.removeAll()
        springArray.springs.removeAll()
        conveyorArray.conveyors.removeAll()
        pieArray.pies.removeAll()
        gameScreen.screenData = Screens().getScreenData(level: gameScreen.level)
        gameScreen.hasElevators = false
        gameScreen.hasSprings = false
        gameScreen.hasFlames = false
        gameScreen.hasLoftLadders = false
        jumpMan.reset()
        pauline.facing = .right
        pauline.isRescued = false
        checkCounter = 0
        switch gameScreen.level {
        case GameConstants.Barrels:
            setLevel1()
        case GameConstants.PieFactory:
            setLevel2()
        case GameConstants.Elevators:
            setLevel3()
        case GameConstants.GirderPlugs:
            setLevel4()
        default:
            setLevel1()
        }
    }
    ///Bent Girder Level 1
    func setLevel1() {
        jumpMan.setPosition(xPos: 7, yPos: 27)
        pauline.setPosition(xPos: 14, yPos: 3)
        kong.setPosition(xPos: 6, yPos: 7)
        pauline.isShowing = true
        flames.setPosition(xPos: 4, yPos: 25)
        gameScreen.hasFlames = false
        collectibles.append(Collectible(type: .hammer, xPos: 3, yPos: 9))
        collectibles.append(Collectible(type: .hammer, xPos: 20, yPos: 21))
        jumpMan.calcFromPosition()
    }
    
    ///Pie Factory Level 2
    func setLevel2() {
        jumpMan.setPosition(xPos: 3, yPos: 27)
        kong.setPosition(xPos: 21, yPos: 7)
        kong.direction = .left
        pauline.setPosition(xPos: 14, yPos: 3)
        pauline.isShowing = true
        flames.setPosition(xPos: 15, yPos: 12)
        gameScreen.hasFlames = true
        collectibles.append(Collectible(type: .hammer, xPos: 14, yPos: 20))
        collectibles.append(Collectible(type: .hammer, xPos: 3, yPos: 15))
        collectibles.append(Collectible(type: .umbrella, xPos: 24, yPos: 17))
        collectibles.append(Collectible(type: .hat, xPos: 9, yPos: 17))
        collectibles.append(Collectible(type: .phone, xPos: 16, yPos: 27))
        gameScreen.hasConveyor = true
        conveyorArray.conveyors.append(Conveyor(xPos: 1, yPos: 8, direction: .left))
        conveyorArray.conveyors.append(Conveyor(xPos: 27, yPos: 8, direction: .right))
        conveyorArray.conveyors.append(Conveyor(xPos: 1, yPos: 13, direction: .left))
        conveyorArray.conveyors.append(Conveyor(xPos: 27, yPos: 13, direction: .right))
        conveyorArray.conveyors.append(Conveyor(xPos: 13, yPos: 13, direction: .right))
        conveyorArray.conveyors.append(Conveyor(xPos: 16, yPos: 13, direction: .left))
        conveyorArray.conveyors.append(Conveyor(xPos: 0, yPos: 23, direction: .left))
        conveyorArray.conveyors.append(Conveyor(xPos: 28, yPos: 23, direction: .right))
        loftLadders.leftLadder = LoftLadder(xPos: 4, yPos: 10)
        loftLadders.rightLadder = LoftLadder(xPos: 24, yPos: 10)
        gameScreen.hasLoftLadders = true
    }
    
    ///Lifts or Elevators Level 3
    func setLevel3() {
        gameScreen.hasSprings  = true
        jumpMan.setPosition(xPos: 1, yPos: 25)
        //jumpMan.setPosition(xPos: 21, yPos: 17)
        pauline.setPosition(xPos: 14, yPos: 3)
        pauline.isShowing = true
        kong.setPosition(xPos: 5, yPos: 7)
        collectibles.append(Collectible(type: .phone, xPos: 27, yPos: 9))
        collectibles.append(Collectible(type: .umbrella, xPos: 1, yPos: 13))
        collectibles.append(Collectible(type: .hat, xPos: 9, yPos: 22))
        elevatorsArray.add(direction: .up,part: .control, xPos: 4, yPos: 27)
        elevatorsArray.add(direction: .up,part: .control, xPos: 12, yPos: 27)
        elevatorsArray.add(direction: .down,part: .control, xPos: 4, yPos: 9)
        elevatorsArray.add(direction: .down,part: .control, xPos: 12, yPos: 9)
        gameScreen.hasElevators = true
        fireBlobArray.add(xPos: 27, yPos: 9,state: .moving)
        fireBlobArray.add(xPos: 9, yPos: 13,state: .moving)
    }
    
    ///Girder Plugs Level 4
    func setLevel4() {
        gameScreen.girderPlugs = 0
        jumpMan.setPosition(xPos: 3, yPos: 27)
        kong.setPosition(xPos: 14, yPos: 7)
        pauline.setPosition(xPos: 15, yPos: 2)
        pauline.isShowing = true
        gameScreen.hasFlames = false
        collectibles.append(Collectible(type: .hammer, xPos: 14, yPos: 10))
        collectibles.append(Collectible(type: .hammer, xPos: 1, yPos: 15))
        collectibles.append(Collectible(type: .umbrella, xPos: 4, yPos: 7))
        collectibles.append(Collectible(type: .hat, xPos: 26, yPos: 22))
        collectibles.append(Collectible(type: .phone, xPos: 17, yPos: 27))
    }
    
    func startBonusCountdown() {
        if !gameScreen.levelEnd && !gameScreen.gameOver {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                bonus -= 100
                if bonus > 0 && gameState == .playing {
                    startBonusCountdown()
                }
            }
        }
    }
    /// todo change the time to 20 seconds
    func startHammerCountdown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [self] in
            jumpMan.removeHammer()
        }
    }
    
    /// Sound FX of the game
    func startHeartBeat(){
        if gameState == .playing {
            soundFX.backgroundSound()
                DispatchQueue.main.asyncAfter(deadline: .now() + heartBeat) { [self] in
                    startHeartBeat()
                }
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
}
