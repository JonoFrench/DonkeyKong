//
//  GameManager+Notifications.swift
//  DonkeyKong
//
//  Created by Jonathan French on 28.08.24.
//

import Foundation
import SwiftUI

extension Notification.Name {
    static let notificationBarrelToFireblob = Notification.Name("NotificationBarrelToFireblob")
    static let notificationRemoveBarrel = Notification.Name("NotificationRemoveBarrel")
    static let notificationRemoveExplosion = Notification.Name("NotificationRemoveExplosion")
    static let notificationRemoveScore = Notification.Name("NotificationRemoveScore")
    static let notificationNextLevel = Notification.Name("NotificationNextLevel")
    static let notificationHowHigh = Notification.Name("NotificationHowHigh")
    static let notificationLevelComplete = Notification.Name("NotificationLevelComplete")
    static let notificationKongAngry = Notification.Name("NotificationKongAngry")
    static let notificationRemoveSpring = Notification.Name("NotificationRemoveSpring")

}

extension GameManager {
    
    func notificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.barrelToFireblob(notification:)), name: .notificationBarrelToFireblob, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeBarrel(notification:)), name: .notificationRemoveBarrel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeExplosion(notification:)), name: .notificationRemoveExplosion, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeScore(notification:)), name: .notificationRemoveScore, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.nextLevel(notification:)), name: .notificationNextLevel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showHowHighView(notification:)), name: .notificationHowHigh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.levelComplete(notification:)), name: .notificationLevelComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.kongAngry(notification:)), name: .notificationKongAngry, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeSpring(notification:)), name: .notificationRemoveSpring, object: nil)

    }
    
    @objc func removeScore(notification: Notification) {
        hasPoints = false
    }
    
    @objc func kongAngry(notification: Notification) {
        if gameState == .playing {
            kong.animateAngry()
        }
    }

    @objc func removeSpring(notification: Notification) {
        if let id = notification.userInfo?["id"] as? UUID {
            if let index = springArray.springs.firstIndex(where: {$0.id == id}) {
                springArray.springs.remove(at: index)
            }
        }
    }
    
    @objc func removeExplosion(notification: Notification) {
        if let position = notification.userInfo?["pos"] as? CGPoint {
            hasExplosion = false
            if !hasPoints {
                addPoints(value: 100, position: position)
            }
        }
    }
    
    @objc func barrelToFireblob(notification: Notification) {
        hasFlames = true
        addfireBlob()
        if let id = notification.userInfo?["id"] as? UUID {
            removeBarrel(id: id)
        }
    }
    
    @objc func removeBarrel(notification: Notification) {
        if let id = notification.userInfo?["id"] as? UUID {
            if let index = barrelArray.barrels.firstIndex(where: {$0.id == id}) {
                barrelArray.barrels.remove(at: index)
            }
        }
    }
    
    @objc func nextLevel(notification: Notification) {
        level += 1
        soundFX.howHighSound()
        showHowHighView(notification: notification)
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
        kong.isThrowing = true
        pauline.isRescued = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            levelEnd = true
            score += bonus
            heart.type = .heartbreak
            self.heart.objectWillChange.send()
            kong.exitLevel()
            pauline.isShowing = false
        }
    }
}
