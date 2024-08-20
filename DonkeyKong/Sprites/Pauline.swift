//
//  Pauline.swift
//  DonkeyKong
//
//  Created by Jonathan French on 17.08.24.
//

import Foundation
import SwiftUI

class Pauline: ObservableObject {
    let animateFrames = 20
    var animateCounter = 0
    var cFrame = 0
    var xPos = 0
    var yPos = 0
    var position = CGPoint()
    var frame = 0
    @Published
    var currentFrame:ImageResource = ImageResource(name: "Pauline1", bundle: .main)
    var standing:[ImageResource] = [ImageResource(name: "Pauline1", bundle: .main),ImageResource(name: "Pauline2", bundle: .main),ImageResource(name: "Pauline3", bundle: .main),ImageResource(name: "Pauline4", bundle: .main)]
    var frameSize: CGSize = CGSize(width: 63, height:  36)
    @Published
    var isShowing = false

    
    func animate() {
        animateCounter += 1
        if animateCounter == animateFrames {
            currentFrame = standing[cFrame]
            cFrame += 1
            if cFrame == 4 {
                cFrame = 0
            }
            animateCounter = 0
        }
    }
}
