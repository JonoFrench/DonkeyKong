//
//  Points.swift
//  DonkeyKong
//
//  Created by Jonathan French on 25.08.24.
//

import Foundation
import SwiftUI

class Points: ObservableObject {
    let animateFrames = 9
    var animateCounter = 0
    var pointsText = "100"
    var xPos = 0
    var yPos = 0
    var cFrame = 0
    var position = CGPoint()
    var frameSize: CGSize = CGSize(width: 32, height:  32)
    var pointsColor = Color.white
    var pointsSwitch = false
}
