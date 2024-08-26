//
//  Explode.swift
//  DonkeyKong
//
//  Created by Jonathan French on 25.08.24.
//

import Foundation
import SwiftUI

class Explode: ObservableObject {
//    var id = UUID()
    let animateFrames = 9
    var animateCounter = 0
    var cFrame = 0
    var xPos = 0
    var yPos = 0
    var position = CGPoint()
    var frame = 0
    @Published
    var currentFrame:ImageResource = ImageResource(name: "Explode1", bundle: .main)
    var explosions:[ImageResource] = [ImageResource(name: "Explode1", bundle: .main),ImageResource(name: "Explode2", bundle: .main),ImageResource(name: "Explode1", bundle: .main),ImageResource(name: "Explode2", bundle: .main),ImageResource(name: "Explode3", bundle: .main),ImageResource(name: "Explode4", bundle: .main),ImageResource(name: "Explode4", bundle: .main)]
    var frameSize: CGSize = CGSize(width: 32, height:  32)
    @Published
    var isShowing = false

//    func animate() {
//        animateCounter += 1
//        if animateCounter == animateFrames {
//            currentFrame = explosions[cFrame]
//            cFrame += 1
//            if cFrame == 6 {
//                cFrame = 0
//            }
//            animateCounter = 0
//        }
//    }
}
