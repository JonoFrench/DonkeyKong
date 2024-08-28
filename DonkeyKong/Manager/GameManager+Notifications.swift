//
//  GameManager+Notifications.swift
//  DonkeyKong
//
//  Created by Jonathan French on 28.08.24.
//

import Foundation

extension Notification.Name {
    static let notificationBarrelToFireblob = Notification.Name("NotificationBarrelToFireblob")
    static let notificationRemoveBarrel = Notification.Name("NotificationRemoveBarrel")
    static let notificationRemoveExplosion = Notification.Name("NotificationRemoveExplosion")
    static let notificationRemoveScore = Notification.Name("NotificationRemoveScore")
    static let notificationNextLevel = Notification.Name("NotificationNextLevel")
    static let notificationHowHigh = Notification.Name("NotificationHowHigh")

}


extension GameManager {
    
    func notificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.barrelToFireblob(notification:)), name: .notificationBarrelToFireblob, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeBarrel(notification:)), name: .notificationRemoveBarrel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeExplosion(notification:)), name: .notificationRemoveExplosion, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeScore(notification:)), name: .notificationRemoveScore, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.nextLevel(notification:)), name: .notificationNextLevel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showHowHighView(notification:)), name: .notificationHowHigh, object: nil)

    }
    
    @objc func removeScore(notification: Notification) {
        hasPoints = false
    }
    
    @objc func removeExplosion(notification: Notification) {
        if let position = notification.userInfo?["position"] as? CGPoint {
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
}


