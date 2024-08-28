//
//  Flames.swift
//  DonkeyKong
//
//  Created by Jonathan French on 18.08.24.
//

import Foundation
import SwiftUI

class Flames:SwiftUISprite, Animatable, ObservableObject {
    static var animateFrames:Int = 17
    var animateCounter: Int = 0

    @Published
    var isLeft = false
    
    override init(xPos: Int, yPos: Int, frameSize: CGSize) {
        super.init(xPos: xPos, yPos: yPos, frameSize: frameSize)
        currentFrame = ImageResource(name: "Flames", bundle: .main)
    }

    override func setPosition(xPos: Int, yPos: Int) {
        super.setPosition(xPos: xPos, yPos: yPos)
        position.y += 4
        position.x -= 8
    }
    
    func animate() {
        animateCounter += 1
        if animateCounter == Flames.animateFrames {
            isLeft = !isLeft
            animateCounter = 0
        }
    }
}
