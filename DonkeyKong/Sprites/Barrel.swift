//
//  Barrel.swift
//  DonkeyKong
//
//  Created by Jonathan French on 20.08.24.
//

import Foundation
import SwiftUI

enum BarrelDirection {
    case left,right,down,leftDown,rightDown
}

enum BarrelColor {
    case orange,blue
}

class BarrelArray: ObservableObject {
    @Published var barrels: [Barrel] = []
}

class Barrel: ObservableObject {    
    var id = UUID()
    let moveFrames = 4
    let animateFrames = 9
    var animateCounter = 0
    var moveCounter = 0
    var speedCounter = 0
    var speed = 2
    var cFrame = 0
    var xPos = 0
    var yPos = 0
    @Published
    var position = CGPoint()
    var frame = 0
    var direction:BarrelDirection = .right
    var nextDirection:BarrelDirection = .left
    var color: BarrelColor = .orange
    var currentHeightOffset = 0.0
    var dropHeight = 0.0
    var dropStep = 0.0
    var dropCount = 0
    var currentFrame:ImageResource = ImageResource(name: "Barrel1", bundle: .main)
    var orangeBarrels:[ImageResource] = [ImageResource(name: "Barrel1", bundle: .main),ImageResource(name: "Barrel2", bundle: .main),ImageResource(name: "Barrel3", bundle: .main),ImageResource(name: "Barrel4", bundle: .main)]
    var blueBarrels:[ImageResource] = [ImageResource(name: "BarrelBlue1", bundle: .main),ImageResource(name: "BarrelBlue2", bundle: .main),ImageResource(name: "BarrelBlue3", bundle: .main),ImageResource(name: "BarrelBlue4", bundle: .main)]
    var orangeDroppingBarrels:[ImageResource] = [ImageResource(name: "BarrelDown", bundle: .main),ImageResource(name: "BarrelDown", bundle: .main),ImageResource(name: "BarrelDown", bundle: .main),ImageResource(name: "BarrelDown", bundle: .main)]
    var blueDroppingBarrels:[ImageResource] = [ImageResource(name: "BarrelBlueDown", bundle: .main),ImageResource(name: "BarrelBlueDown2", bundle: .main),ImageResource(name: "BarrelBlueDown", bundle: .main),ImageResource(name: "BarrelBlueDown2", bundle: .main)]

    var frameSize: CGSize = CGSize(width: 16, height:  16)
    var isShowing = true
    var droppingDown = false
    var isThrown = false
    
    func animate() {
        animateCounter += 1
        if animateCounter == animateFrames {
            if color == .blue {
                if droppingDown || isThrown {
                    currentFrame = blueDroppingBarrels[cFrame]
                } else {
                    currentFrame = blueBarrels[cFrame]
                }
            } else {
                if droppingDown {
                    currentFrame = orangeDroppingBarrels[cFrame]
                } else {
                    currentFrame = orangeBarrels[cFrame]
                }
            }
            cFrame += 1
            if cFrame == 4 {
                cFrame = 0
            }
            animateCounter = 0
        }
    }
}
