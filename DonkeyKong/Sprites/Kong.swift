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
    var position = CGPoint()
    @Published
    var currentFrame:ImageResource = ImageResource(name: "KongClimbRight", bundle: .main)
    let kongClimbLeft:ImageResource = ImageResource(name: "KongClimbLeft", bundle: .main)
    let kongClimbRight:ImageResource = ImageResource(name: "KongClimbRight", bundle: .main)
    let kongFacing:ImageResource = ImageResource(name: "KongFacing", bundle: .main)
    let kongLeft:ImageResource = ImageResource(name: "KongThrowLeft", bundle: .main)
    let kongRight:ImageResource = ImageResource(name: "KongThrowRight", bundle: .main)
    let kongDown:ImageResource = ImageResource(name: "KongThrowDown", bundle: .main)
    var kongStep = false
    var frameSize: CGSize = CGSize(width: 72, height:  72)
    var jumpingPoints:[Int] = [11,10,9,8,7,8]
    var bouncingPoints = [[CGPoint]]()
    var animationCounter = 0
    var bouncePos = 0
    var bounceYPos = 0
    var isThrowing =  false

}
