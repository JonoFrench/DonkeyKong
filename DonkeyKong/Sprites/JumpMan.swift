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
struct JumpMan {
    var xPos = 0
    var yPos = 0
    var hasHammer = false
    var hammerFrame = false
    var jumpManPosition = CGPoint()
    var frameSize: CGSize = CGSize(width: 30, height:  25)
    var animateFrame = 0
    var facing:JMDirection = .right
    var currentFrame:ImageResource = ImageResource(name: "JM1", bundle: .main)
    
    var walking:[ImageResource] = [ImageResource(name: "JM2", bundle: .main),ImageResource(name: "JM3", bundle: .main),ImageResource(name: "JM1", bundle: .main)]
    var climbing:[ImageResource] = [ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb2", bundle: .main),ImageResource(name: "JMClimb1", bundle: .main),ImageResource(name: "JMClimb2", bundle: .main)]
    var climbing2:[ImageResource] = [ImageResource(name: "JMClimb2", bundle: .main),ImageResource(name: "JMClimb3", bundle: .main),ImageResource(name: "JMBack", bundle: .main)]

    var hammer1:[ImageResource] = [ImageResource(name: "JMHam1", bundle: .main),ImageResource(name: "JMHam3", bundle: .main),ImageResource(name: "JMHam2", bundle: .main)]
    var hammer2:[ImageResource] = [ImageResource(name: "JMHam4", bundle: .main),ImageResource(name: "JMHam6", bundle: .main),ImageResource(name: "JMHam5", bundle: .main)]

    
    func calcPositionFromGrid(gameSize:CGSize, assetDimention: Double, xPos:Int,yPos:Int,heightAdjust:Double ) -> CGPoint {
        let heightFactor = (gameSize.height - ( 27.0 * assetDimention)) / 4
        let heightPos = assetDimention * Double(yPos)
        return CGPoint(x: (gameSize.width / assetDimention) * Double(xPos) + (frameSize.width / 4), y: heightPos + heightFactor + frameSize.height )
    }
    
    func calcGridPositionFromPoint(gameSize: CGSize, assetDimention: Double) -> (xPos: Int, yPos: Int) {
        let heightFactor = (gameSize.height - (28.0 * assetDimention)) / 4
        
        let adjustedY = jumpManPosition.y - heightFactor - (gameSize.height / 2)
        let yPos = Int(adjustedY / assetDimention)
        
        let adjustedX = jumpManPosition.x - (gameSize.width / 2)
        let xPos = Int(adjustedX / (gameSize.width / assetDimention))
        
        return (xPos: xPos, yPos: yPos)
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
