//
//  GameManager+Notifications.swift
//  DonkeyKong
//
//  Created by Jonathan French on 28.08.24.
//

import Foundation
import SwiftUI
#if os(tvOS)
import GameController
#endif
extension Notification.Name {
    static let notificationBarrelToFireblob = Notification.Name("NotificationBarrelToFireblob")
    static let notificationPieToFireblob = Notification.Name("NotificationPieToFireblob")
    static let notificationRemoveBarrel = Notification.Name("NotificationRemoveBarrel")
    static let notificationRemovePie = Notification.Name("NotificationRemovePie")
    static let notificationRemoveExplosion = Notification.Name("NotificationRemoveExplosion")
    static let notificationRemoveScore = Notification.Name("NotificationRemoveScore")
    static let notificationNextLevel = Notification.Name("NotificationNextLevel")
    static let notificationHowHigh = Notification.Name("NotificationHowHigh")
    static let notificationLevelComplete = Notification.Name("NotificationLevelComplete")
    static let notificationKongAngry = Notification.Name("NotificationKongAngry")
    static let notificationRemoveSpring = Notification.Name("NotificationRemoveSpring")
    static let notificationGirderPlug = Notification.Name("NotificationGirderPlug")
    static let notificationJumpManDead = Notification.Name("NotificationJumpManDead")
    static let notificationNewGame = Notification.Name("NotificationNewGame")

}

extension GameManager {
    
    func notificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.barrelToFireblob(notification:)), name: .notificationBarrelToFireblob, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.pieToFireblob(notification:)), name: .notificationPieToFireblob, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeBarrel(notification:)), name: .notificationRemoveBarrel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removePie(notification:)), name: .notificationRemovePie, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeExplosion(notification:)), name: .notificationRemoveExplosion, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeScore(notification:)), name: .notificationRemoveScore, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.nextLevel(notification:)), name: .notificationNextLevel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showHowHighView(notification:)), name: .notificationHowHigh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.levelComplete(notification:)), name: .notificationLevelComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.kongAngry(notification:)), name: .notificationKongAngry, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeSpring(notification:)), name: .notificationRemoveSpring, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.girderPlug(notification:)), name: .notificationGirderPlug, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.jumpmanDead(notification:)), name: .notificationJumpManDead, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.nextGame(notification:)), name: .notificationNewGame, object: nil)

        
        
#if os(tvOS)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidConnect),
            name: .GCControllerDidConnect,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidDisconnect),
            name: .GCControllerDidDisconnect,
            object: nil
        )
#endif
        
    }
    
    @objc func removeScore(notification: Notification) {
        gameScreen.hasPoints = false
    }
    
    @objc func kongAngry(notification: Notification) {
        if gameState == .playing && !gameScreen.levelEnd {
            kong.animateAngry()
        }
    }
    
    @objc func girderPlug(notification: Notification) {
        gameScreen.girderPlugs += 1
        soundFX.getItemSound()
        if gameScreen.girderPlugs == 8 {
            ///End of level 4!
            gameScreen.levelEnd = true
            fireBlobArray.fireblob.removeAll()
            collectibles.removeAll()
            gameScreen.clearFinalLevel()
            collectibles.append(heart)
            pauline.isRescued = true
            jumpMan.facing = .right
            jumpMan.setPosition(xPos: 12, yPos: 2)
            pauline.setPosition(xPos: 15, yPos: 2)
            pauline.facing = .left
            heart.setPosition(xPos: 14, yPos: 0)
            score += bonus
            soundFX.win1Sound()
            kong.exitLevel(level: gameScreen.level)
        }
    }
    
    @objc func removePie(notification: Notification) {
        if let id = notification.userInfo?["id"] as? UUID {
            barrelArray.remove(id: id)
        }
    }
    
    @objc func removeSpring(notification: Notification) {
        if let id = notification.userInfo?["id"] as? UUID {
            springArray.remove(id: id)
        }
    }
    
    @objc func removeExplosion(notification: Notification) {
        if let position = notification.userInfo?["pos"] as? CGPoint {
            gameScreen.hasExplosion = false
            if !gameScreen.hasPoints {
                addPoints(value: 100, position: position)
            }
        }
    }
    
    @objc func barrelToFireblob(notification: Notification) {
        gameScreen.hasFlames = true
        fireBlobArray.add()
        if let id = notification.userInfo?["id"] as? UUID {
            barrelArray.remove(id: id)
        }
    }
    
    @objc func pieToFireblob(notification: Notification) {
        fireBlobArray.add(xPos: 14 + Int.random(in: 0...1), yPos: 12,state: .sitting)
        if let id = notification.userInfo?["id"] as? UUID {
            pieArray.remove(id: id)
        }
    }
    
    @objc func removeBarrel(notification: Notification) {
        if let id = notification.userInfo?["id"] as? UUID {
            barrelArray.remove(id: id)
        }
    }
    
    @objc func jumpmanDead(notification: Notification) {
        lives -= 1
        if lives > 0 {
            soundFX.howHighSound()
            showHowHighView(notification: notification)
        } else {
            gameScreen.gameOver = true
            soundFX.gameOverSound()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [self] in
                if hiScores.isNewHiScore(score: score) {
                    hiScores.resetInput()
                    gameState = .highscore
                } else {
                    gameState = .intro
                }
            }
        }
    }

    
    @objc func nextLevel(notification: Notification) {
        gameScreen.level += 1
            soundFX.howHighSound()
            showHowHighView(notification: notification)
    }
    
    @objc func nextGame(notification: Notification) {
        gameState = .intro
    }
    
    @objc func showHowHighView(notification: Notification){
        gameState = .howhigh
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [self] in
            startPlaying()
        }
    }
    
    @objc func levelComplete(notification: Notification){
        heart.setPosition()
        collectibles.removeAll()
        collectibles.append(heart)
        barrelArray.barrels.removeAll()
        fireBlobArray.fireblob.removeAll()
        pieArray.pies.removeAll()
        springArray.springs.removeAll()
        kong.isThrowing = true
        pauline.isRescued = true
        soundFX.endLevelSound()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            gameScreen.levelEnd = true
            score += bonus
            heart.type = .heartbreak
            self.heart.objectWillChange.send()
            kong.exitLevel(level: gameScreen.level)
            pauline.isShowing = false
        }
    }
    
#if os(tvOS)
    @objc func controllerDidConnect(notification: Notification) {
        if let controller = notification.object as? GCController {
            // Set up your controller
            setupController(controller)
        }
    }

    @objc func controllerDidDisconnect(notification: Notification) {
        // Handle controller disconnection if needed
    }
    #endif
}
