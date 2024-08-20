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
class JumpMan: ObservableObject {
    var xPos = 0
    var yPos = 0
    let animationFrames = 4
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
    
    @Published
    var hasHammer = false
    var hammerFrame = false
    @Published
    var position = CGPoint()
    //var frameSize: CGSize = CGSize(width: 30, height:  25)
    var frameSize: CGSize = CGSize(width: 24, height:  24)
    var animateFrame = 0
    var jumpingFrame = 0
    @Published
    var facing:JMDirection = .right
    @Published
    var currentFrame:ImageResource = ImageResource(name: "JM1", bundle: .main)
    
    var walking:[ImageResource] = [ImageResource(name: "JM2", bundle: .main),ImageResource(name: "JM3", bundle: .main),ImageResource(name: "JM1", bundle: .main)]
    var climbing:[ImageResource] = [ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb1", bundle: .main)]
    var climbing2:[ImageResource] = [ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb2", bundle: .main),ImageResource(name: "JMClimb3", bundle: .main),ImageResource(name: "JMBack", bundle: .main)]

    var hammer1:[ImageResource] = [ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam3", bundle: .main),ImageResource(name: "JMHam2", bundle: .main)]
    var hammer2:[ImageResource] = [ImageResource(name: "JMHam4", bundle: .main),ImageResource(name: "JMHam6", bundle: .main),ImageResource(name: "JMHam5", bundle: .main)]
  
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
