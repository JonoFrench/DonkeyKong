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
    @Published
    var gameState:GameState = .intro
    @Published
    var lives = 3
    var score = 0
    var level = 1
    @Published
    var bonus = 5000
    ///Sprites of sorts....
    @ObservedObject
    var jumpMan:JumpMan = JumpMan(xPos: 0, yPos: 0, frameSize: CGSize(width: 32, height:  32))
    @ObservedObject
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
                jumpMan.move()
                jumpMan.animate()
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
                        checkBarrelHit(barrel: barrel)
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
    }
    
    func setDataForLevel() {
        collectibles.removeAll()
        barrelArray.barrels.removeAll()
        fireBlobArray.fireblob.removeAll()
        gameScreen.screenData = Screens().getScreenData(level: self.level)
        jumpMan.facing = .right
        if level == 1 {
            jumpMan.setPosition(xPos: 6, yPos: 27)
            pauline.setPosition(xPos: 14, yPos: 3)
            
            kong.setPosition(xPos: 6, yPos: 7)
            pauline.isShowing = true
            flames.setPosition(xPos: 4, yPos: 25)
            hasFlames = false
            collectibles.append(Collectible(type: .hammer, xPos: 3, yPos: 9))
            collectibles.append(Collectible(type: .hammer, xPos: 20, yPos: 21))
        } else if level == 2 {
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
        } else if level == 3 {
            jumpMan.setPosition(xPos: 3, yPos: 27)
            kong.setPosition(xPos: 21, yPos: 7)
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
            jumpMan.setPosition(xPos: 1, yPos: 25)
            pauline.setPosition(xPos: 14, yPos: 3)
            pauline.isShowing = true
            kong.setPosition(xPos: 21, yPos: 7)
            collectibles.append(Collectible(type: .phone, xPos: 27, yPos: 9))
            collectibles.append(Collectible(type: .umbrella, xPos: 1, yPos: 13))
            collectibles.append(Collectible(type: .hat, xPos: 9, yPos: 22))
        }
    }
    
    func startBonusCountdown() {
        if !levelEnd {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                bonus -= 100
                if bonus > 0 {
                    startBonusCountdown()
                }
            }
        }
    }
    /// todo change the time to 30 seconds
    func startHammerCountdown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [self] in
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
