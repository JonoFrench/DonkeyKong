//
//  Kong.swift
//  DonkeyKong
//
//  Created by Jonathan French on 16.08.24.
//

import Foundation
import SwiftUI

enum KongState {
    case waiting,intro,jumpingup,bouncing,sitting,throwing,howhigh,dead
}

struct Kong {
    var xPos = 0
    var yPos = 0
    var state:KongState = .waiting
    var kongPosition = CGPoint()
    var currentFrame:ImageResource = ImageResource(name: "KongClimbRight", bundle: .main)
    let kongClimbLeft:ImageResource = ImageResource(name: "KongClimbLeft", bundle: .main)
    let kongClimbRight:ImageResource = ImageResource(name: "KongClimbRight", bundle: .main)
    let kongFacing:ImageResource = ImageResource(name: "KongFacing", bundle: .main)
    var kongStep = false
    var frameSize: CGSize = CGSize(width: 96, height:  96)
    var jumpingPoints:[Int] = [5,4,3,2,1,2]
    var bouncingPoints = [[CGPoint]]()

    
}
