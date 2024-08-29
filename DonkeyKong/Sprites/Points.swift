//
//  Points.swift
//  DonkeyKong
//
//  Created by Jonathan French on 25.08.24.
//

import Foundation
import SwiftUI

final class Points: SwiftUISprite,Animatable, ObservableObject {
    static var animateFrames: Int = 9
    var animateCounter: Int = 0

    var pointsText = "100"
    var pointsColor = Color.white
    var pointsSwitch = false
    /// not doing a lot but display the points colleted.
    func animate() {
        animateCounter += 1
        if animateCounter == Points.animateFrames {
            currentAnimationFrame += 1
            if currentAnimationFrame == 6 {
                currentAnimationFrame = 0
                NotificationCenter.default.post(name: .notificationRemoveScore, object: nil)
            }
            animateCounter = 0
        }
    }
}
