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

class Kong: ObservableObject {
    var xPos = 0
    var yPos = 0
    @Published
    var state:KongState = .waiting
    @Published
    var kongPosition = CGPoint()
    var currentFrame:ImageResource = ImageResource(name: "KongClimbRight", bundle: .main)
    let kongClimbLeft:ImageResource = ImageResource(name: "KongClimbLeft", bundle: .main)
    let kongClimbRight:ImageResource = ImageResource(name: "KongClimbRight", bundle: .main)
    let kongFacing:ImageResource = ImageResource(name: "KongFacing", bundle: .main)
    var kongStep = false
    var frameSize: CGSize = CGSize(width: 72, height:  72)
    var jumpingPoints:[Int] = [11,10,9,8,7,8]
    var bouncingPoints = [[CGPoint]]()

}
