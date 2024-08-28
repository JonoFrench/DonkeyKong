//
//  JumpMan.swift
//  DonkeyKong
//
//  Created by Jonathan French on 13.08.24.
//

import Foundation
import SwiftUI

enum JMState {
    case still,walking,climbingUp,climbingDown,hammer,dead
}
enum JMDirection {
    case left,right
}
class JumpMan:SwiftUISprite, ObservableObject {
    let speed = 3
    var speedCounter = 0
    var isWalking = false
    var isWalkingRight = false
    var isWalkingLeft = false
    var isClimbing = false
    var isClimbingUp = false
    var isClimbingDown = false
    var startedClimbing = false
    var willJump = false
    var isJumping = false
    var isJumpingUp = false
    var isJumpingLeft = false
    var isJumpingRight = false
    var jumpingPoints = [CGPoint]()
    var ladderHeight = 0.0
    var ladderStep = 0.0

    @Published
    var hasHammer = false
    var hammerFrameSize: CGSize = CGSize(width: 64, height:  64)
    var normalFrameSize: CGSize = CGSize(width: 32, height:  32)
    var animateFrame = 0
    var jumpingFrame = 0
    var animateHammerFrame = 0
    @Published
    var facing:JMDirection = .right
    
    var walking:[ImageResource] = [ImageResource(name: "JM2", bundle: .main),ImageResource(name: "JM3", bundle: .main),ImageResource(name: "JM1", bundle: .main)]
    var climbing:[ImageResource] = [ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb1", bundle: .main)]
    var climbing2:[ImageResource] = [ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb2", bundle: .main),ImageResource(name: "JMClimb3", bundle: .main),ImageResource(name: "JMBack", bundle: .main)]

    var hammer1:[ImageResource] = [ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main),ImageResource(name: "JMHam2", bundle: .main)]
    var hammerWalking:[ImageResource] = [ImageResource(name: "JMHam3", bundle: .main),ImageResource(name: "JMHam3", bundle: .main),ImageResource(name: "JMHam3", bundle: .main),ImageResource(name: "JMHam3", bundle: .main),ImageResource(name: "JMHam4", bundle: .main),ImageResource(name: "JMHam4", bundle: .main),ImageResource(name: "JMHam4", bundle: .main),ImageResource(name: "JMHam4", bundle: .main),ImageResource(name: "JMHam5", bundle: .main),ImageResource(name: "JMHam5", bundle: .main),ImageResource(name: "JMHam5", bundle: .main),ImageResource(name: "JMHam5", bundle: .main),ImageResource(name: "JMHam6", bundle: .main),ImageResource(name: "JMHam6", bundle: .main),ImageResource(name: "JMHam6", bundle: .main),ImageResource(name: "JMHam6", bundle: .main)]

    override init(xPos: Int, yPos: Int, frameSize: CGSize) {
        super.init(xPos: xPos, yPos: yPos, frameSize: frameSize)
        currentFrame = ImageResource(name: "JM1", bundle: .main)
    }
    
    func canJump()-> Bool {
        if jumpingPoints.isEmpty { return true }
        return false
    }
    
    func directionFacing() -> CGSize {
        switch facing {
        case .left:
            return CGSize(width: -1, height: 1)
        case .right:
            return CGSize(width: 1, height: -1) 
        }
    }
    

}
