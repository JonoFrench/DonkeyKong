//
//  Flames.swift
//  DonkeyKong
//
//  Created by Jonathan French on 18.08.24.
//

import Foundation
import SwiftUI

class Flames: ObservableObject {
    let animateFrames = 17
    var animateCounter = 0
    var xPos = 4
    var yPos = 25
    var position = CGPoint()
    var currentFrame:ImageResource = ImageResource(name: "Flames", bundle: .main)
    var frameSize: CGSize = CGSize(width: 24, height:  24)
    @Published
    var isLeft = false
    
    func animate() {
        animateCounter += 1
        if animateCounter == animateFrames {
            isLeft = !isLeft
            animateCounter = 0
        }
    }
}
