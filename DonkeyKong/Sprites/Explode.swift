//
//  Explode.swift
//  DonkeyKong
//
//  Created by Jonathan French on 25.08.24.
//

import Foundation
import SwiftUI

class Explode: SwiftUISprite,Animatable, ObservableObject {
    static var animateFrames: Int = 9
    var animateCounter: Int = 0
    var explosions:[ImageResource] = [ImageResource(name: "Explode1", bundle: .main),ImageResource(name: "Explode2", bundle: .main),ImageResource(name: "Explode1", bundle: .main),ImageResource(name: "Explode2", bundle: .main),ImageResource(name: "Explode3", bundle: .main),ImageResource(name: "Explode4", bundle: .main),ImageResource(name: "Explode4", bundle: .main)]

    override init(xPos: Int, yPos: Int, frameSize: CGSize) {
        super.init(xPos: xPos, yPos: yPos, frameSize: frameSize)
        currentFrame = ImageResource(name: "Explode1", bundle: .main)
    }
    
    func animate() {
        animateCounter += 1
        if animateCounter == Explode.animateFrames {
            currentFrame = explosions[currentAnimationFrame]
            currentAnimationFrame += 1
            if currentAnimationFrame == 6 {
                currentAnimationFrame = 0
                let position:[String: CGPoint] = ["pos": self.position]
                NotificationCenter.default.post(name: .notificationRemoveExplosion, object: nil, userInfo: position)
            }
            animateCounter = 0
        }
    }
}
