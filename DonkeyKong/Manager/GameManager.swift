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

struct AppConstant {
    static let Barrels = 1
    static let PieFactory = 2
    static let Elevators = 3
    static let GirderPlugs = 4
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
    var level = 1
    @Published
    var bonus = 5000
    ///Sprites of sorts....
    @ObservedObject
    var jumpMan:JumpMan = JumpMan(xPos: 0, yPos: 0, frameSize: CGSize(width: 32, height:  32))
    @ObservedObject
    var kong:Kong = Kong(xPos: 0, yPos: 0, frameSize: CGSize(width: 60, height:  60))
    var pauline:Pauline = Pauline(xPos: 0, yPos: 0, frameSize: CGSize(width: 63, height:  36))
    let heartBeat = 0.6
    var flames:Flames = Flames(xPos: 0, yPos: 0, frameSize: CGSize(width: 24, height:  24))
    var collectibles:[Collectible] = []
    @ObservedObject
    var elevatorsArray:ElevatorArray = ElevatorArray()
    @ObservedObject
    var barrelArray:BarrelArray = BarrelArray()
    @ObservedObject
    var fireBlobArray:FireBlobArray = FireBlobArray()
    @ObservedObject
    var springArray:SpringArray = SpringArray()
    @ObservedObject
    var pieArray:PieArray = PieArray()

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
    var hasElevators = false
    var hasSprings = false
    var springAdded = false
    var hasConveyor = false
    @ObservedObject
    var conveyorArray:ConveyorArray = ConveyorArray()
    @ObservedObject
    var loftLadders = Ladders()
    var hasLoftLadders = false
    var moveDirection: JoyPad {
        didSet {
            if moveDirection != oldValue {
                handleJoyPad()
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
        ServiceLocator.shared.register(service: soundFX)

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
    
    func handleJoyPad() {
        switch moveDirection {
        case .down:
            if gameState == .playing {
                if jumpMan.canDecendLadder() {
                    jumpMan.calculateLadderHeightDown()
                    jumpMan.isClimbingDown = true
                }
            }
        case .left:
            if gameState == .playing {
                if jumpMan.canMoveLeft() {
                    jumpMan.isWalkingLeft = true
                }
            }
        case .right:
            if gameState == .playing {
                if jumpMan.canMoveRight() {
                    jumpMan.isWalkingRight = true
                }
            }
        case .up:
            if gameState == .playing {
                if jumpMan.canClimbLadder() {
                    jumpMan.calculateLadderHeightUp()
                    jumpMan.isClimbingUp = true
                }
            }
        case.stop:
            jumpMan.isWalkingLeft = false
            jumpMan.isWalkingRight = false
            jumpMan.isClimbingDown = false
            jumpMan.isClimbingUp = false
        }
    }
    
    @objc func refreshModel() {
        //handleJoyPad()
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
                jumpMan.move()
                jumpMan.animate()
                pauline.animate()
                if hasFlames {
                    flames.animate()
                }
                if level == AppConstant.Barrels {
                    throwBarrel()
                    
                    for barrel in barrelArray.barrels {
                        barrel.animate()
                        if !barrel.isThrown {
                            barrel.move()
                        } else {
                            barrel.moveThrown()
                        }
                        checkBarrelHit(barrel: barrel)
                    }
                    
                    for fireBlob in fireBlobArray.fireblob {
                        fireBlob.animate()
                        if fireBlob.state == .hopping {
                            fireBlob.hop(state: .moving)
                        } else {
                            fireBlob.move()
                        }
                        checkFireBlobHit(fireBlob: fireBlob)
                    }
                }
                
                if level == AppConstant.PieFactory {
                    kong.moveSlide()
                    addPies()
                    for pie in pieArray.pies {
                        pie.move()
                    }
                    for conveyor in conveyorArray.conveyors {
                        conveyor.animate()
                    }
                    for fireBlob in fireBlobArray.fireblob {
                        fireBlob.animate()
                        if fireBlob.state == .moving {
                            fireBlob.move()
                        } else if fireBlob.state == .sitting {
                            startMovingFireBlob(fireBlob: fireBlob)
                        } else if fireBlob.state == .hopping {
                            fireBlob.hop(state: .moving)
                        }
                        checkFireBlobHit(fireBlob: fireBlob)
                    }
                    loftLadders.leftLadder.animate()
                    loftLadders.rightLadder.animate()
                }
                
                if level == AppConstant.Elevators {
                    throwSpring()
                    for fireBlob in fireBlobArray.fireblob {
                        fireBlob.animate()
                        fireBlob.move()
                        checkFireBlobHit(fireBlob: fireBlob)
                    }
                    
                    for elevator in elevatorsArray.elevators {
                        elevator.move()
                    }
                    elevatorsArray.objectWillChange.send()
                    
                    for spring in springArray.springs {
                        spring.animate()
                        spring.move()
                    }
                }
                
                if level == AppConstant.GirderPlugs {
                    for fireBlob in fireBlobArray.fireblob {
                        fireBlob.animate()
                        fireBlob.move()
                        checkFireBlobHit(fireBlob: fireBlob)
                        fireBlob.hasHammer = jumpMan.hasHammer
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

    func startGame() {
        gameScreen.assetDimention = gameScreen.gameSize.width / Double(gameScreen.screenDimentionX - 1)
        gameScreen.assetOffset = gameScreen.assetDimention / 8.0
        gameScreen.verticalOffset =  -50.0 //(gameSize.height - (assetDimention * 25.0))
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
        if level == AppConstant.Barrels {
            kong.isThrowing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                throwBarrelDown()
            }
        } else if level == AppConstant.PieFactory {
            kong.animateAngry()
            swapConveyorDirection()
        } else if level == AppConstant.Elevators {
            kong.animateAngry()

        } else if level == AppConstant.GirderPlugs {
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
        gameScreen.screenData = Screens().getScreenData(level: self.level)
        hasElevators = false
        hasSprings = false
        hasFlames = false
        hasLoftLadders = false
        jumpMan.facing = .right
        if level == AppConstant.Barrels {
            setLevel1()
        } else if level == AppConstant.PieFactory {
            setLevel2()
        } else if level == AppConstant.Elevators {
            setLevel3()
        } else if level == AppConstant.GirderPlugs {
            setLevel4()
        }
    }
    ///Bent Girder Level 1
    func setLevel1() {
        jumpMan.setPosition(xPos: 6, yPos: 27)
        pauline.setPosition(xPos: 14, yPos: 3)
        kong.setPosition(xPos: 6, yPos: 7)
        pauline.isShowing = true
        flames.setPosition(xPos: 4, yPos: 25)
        hasFlames = false
        collectibles.append(Collectible(type: .hammer, xPos: 3, yPos: 9))
        collectibles.append(Collectible(type: .hammer, xPos: 20, yPos: 21))
    }
    
    ///Pie Factory Level 2
    func setLevel2() {
        jumpMan.setPosition(xPos: 3, yPos: 27)
        kong.setPosition(xPos: 21, yPos: 7)
        kong.direction = .left
        pauline.setPosition(xPos: 14, yPos: 3)
        pauline.isShowing = true
        
        flames.setPosition(xPos: 15, yPos: 12)
        hasFlames = true
        
        collectibles.append(Collectible(type: .hammer, xPos: 14, yPos: 20))
        collectibles.append(Collectible(type: .hammer, xPos: 3, yPos: 15))
        collectibles.append(Collectible(type: .umbrella, xPos: 24, yPos: 17))
        collectibles.append(Collectible(type: .hat, xPos: 9, yPos: 17))
        collectibles.append(Collectible(type: .phone, xPos: 16, yPos: 27))
        hasConveyor = true
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

        
        hasLoftLadders = true
    }
    
    ///Lifts or Elevators Level 3
    func setLevel3() {
        hasSprings  = true
        jumpMan.setPosition(xPos: 1, yPos: 25)
        pauline.setPosition(xPos: 14, yPos: 3)
        pauline.isShowing = true
        kong.setPosition(xPos: 5, yPos: 7)
        collectibles.append(Collectible(type: .phone, xPos: 27, yPos: 9))
        collectibles.append(Collectible(type: .umbrella, xPos: 1, yPos: 13))
        collectibles.append(Collectible(type: .hat, xPos: 9, yPos: 22))
        elevatorsArray.elevators.append(Elevator(direction: .up,part: .lift, xPos: 4, yPos: 26))
        elevatorsArray.elevators.append(Elevator(direction: .up,part: .lift,xPos: 4, yPos: 20))
        elevatorsArray.elevators.append(Elevator(direction: .up,part: .lift,xPos: 4, yPos: 14))
        elevatorsArray.elevators.append(Elevator(direction: .down,part: .lift,xPos: 12, yPos: 14))
        elevatorsArray.elevators.append(Elevator(direction: .down,part: .lift,xPos: 12, yPos: 20))
        elevatorsArray.elevators.append(Elevator(direction: .down,part: .lift,xPos: 12, yPos: 26))
        elevatorsArray.elevators.append(Elevator(direction: .up,part: .control, xPos: 4, yPos: 27))
        elevatorsArray.elevators.append(Elevator(direction: .up,part: .control, xPos: 12, yPos: 27))
        elevatorsArray.elevators.append(Elevator(direction: .down,part: .control, xPos: 4, yPos: 9))
        elevatorsArray.elevators.append(Elevator(direction: .down,part: .control, xPos: 12, yPos: 9))

        hasElevators = true
        addFireBlob(xPos: 27, yPos: 9,state: .moving)
        addFireBlob(xPos: 9, yPos: 13,state: .moving)
    }
    
    ///Girder Plugs Level 4
    func setLevel4() {
        jumpMan.setPosition(xPos: 3, yPos: 27)
        kong.setPosition(xPos: 14, yPos: 7)
        pauline.setPosition(xPos: 15, yPos: 2)
        pauline.isShowing = true
        hasFlames = false
        collectibles.append(Collectible(type: .hammer, xPos: 14, yPos: 10))
        collectibles.append(Collectible(type: .hammer, xPos: 2, yPos: 15))
        collectibles.append(Collectible(type: .umbrella, xPos: 4, yPos: 7))
        collectibles.append(Collectible(type: .hat, xPos: 26, yPos: 22))
        collectibles.append(Collectible(type: .phone, xPos: 17, yPos: 27))
    }
    
    func startBonusCountdown() {
        if !levelEnd {
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
            DispatchQueue.main.asyncAfter(deadline: .now() + heartBeat) { [self] in
                soundFX.backgroundSound()
                DispatchQueue.main.asyncAfter(deadline: .now() + heartBeat) { [self] in
                    soundFX.backgroundSound()
                    startHeartBeat()
                }
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
    
//    func whatsAround() {
//        return
//        print("JumpMan Current position is X \(jumpMan.xPos) Y \(jumpMan.yPos)")
//        print("JumpMan Current screen position is \(jumpMan.position)")
//        print("JumpMan Current height offset is \(jumpMan.currentHeightOffset)")
//        print("Current Standing on is \(screenData[jumpMan.yPos][jumpMan.xPos].assetType)")
//        if jumpMan.xPos == 0 {
//            print("Nothing Behind")
//        } else {
//            print("Behind is \(screenData[jumpMan.yPos-1][jumpMan.xPos - 1].assetType)")
//        }
//        if jumpMan.xPos > gameScreen.screenDimentionX {
//            print("Nothing In front")
//        } else {
//            print("In front is \(screenData[jumpMan.yPos-1][jumpMan.xPos + 1].assetType)")
//        }
//        if jumpMan.yPos == 0 {
//            print("Nothing above")
//        } else {
//            print("Above is \(screenData[jumpMan.yPos - 1][jumpMan.xPos].assetType)")
//        }
//        if jumpMan.yPos == 27 {
//            print("Nothing Below")
//        } else {
//            print("Below is \(screenData[jumpMan.yPos + 1][jumpMan.xPos].assetType)")
//        }
//    }
    
}
