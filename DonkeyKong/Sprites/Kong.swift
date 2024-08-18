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
    var frameSize: CGSize = CGSize(width: 96, height:  96)
    var jumpingPoints:[Int] = [5,4,3,2,1,2]
    var bouncingPoints = [[CGPoint]]()

    
//    func generateBouncingPoints() {
//        var c = 0
//        for i in stride(from: 12, through: 4, by: -2) {
//            var pointA = calcPositionForXY(xPos: i, yPos: kong.yPos,frameSize: kong.frameSize)
//            pointA.y -= 4.0
//            var pointB = calcPositionForXY(xPos: i - 2, yPos: kong.yPos,frameSize: kong.frameSize)
//            pointB.y -= 4.0
//            let points = generateParabolicPoints(from: pointA, to: pointB, angleInDegrees: -50)
//            kong.bouncingPoints.append(points)
//            c += 1
//        }
//    }
}
