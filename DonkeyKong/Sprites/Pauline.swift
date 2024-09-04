//
//  Pauline.swift
//  DonkeyKong
//
//  Created by Jonathan French on 17.08.24.
//

import Foundation
import SwiftUI

enum PaulineDirection {
    case left,right
}

final class Pauline:SwiftUISprite, Animatable, ObservableObject {
    static var animateFrames:Int = 20
    var animateCounter: Int = 0
    
    @Published
    var facing:PaulineDirection = .right

    var standing:[ImageResource] = [ImageResource(name: "Pauline1", bundle: .main),ImageResource(name: "Pauline2", bundle: .main),ImageResource(name: "Pauline3", bundle: .main),ImageResource(name: "Pauline4", bundle: .main)]
    //var frameSize: CGSize = CGSize(width: 63, height:  36)
    var isRescued = false

    override init(xPos: Int, yPos: Int, frameSize: CGSize) {
        super.init(xPos: xPos, yPos: yPos, frameSize: frameSize)
        currentFrame = ImageResource(name: "Pauline1", bundle: .main)
    }

    func animate() {
        if !isRescued {
            animateCounter += 1
            if animateCounter == Pauline.animateFrames {
                currentFrame = standing[currentAnimationFrame]
                currentAnimationFrame += 1
                if currentAnimationFrame == standing.count {
                    currentAnimationFrame = 0
                }
                animateCounter = 0
            }
        }
        else {
            currentFrame = ImageResource(name: "Pauline1", bundle: .main)
        }
    }
}
