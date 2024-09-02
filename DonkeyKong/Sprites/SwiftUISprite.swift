//
//  SwiftUISprite.swift
//  DonkeyKong
//
//  Created by Jonathan French on 27.08.24.
//

import Foundation
import SwiftUI

protocol Animatable {
    static var animateFrames: Int { get } 
    var animateCounter:Int {get set}

    func animate()
}

protocol Moveable {
    static var speed: Int { get }
    var speedCounter:Int {get set}
    
    func move()
}


class SwiftUISprite {
    var id = UUID()
    var xPos = 0
    var yPos = 0
    var currentHeightOffset = 0.0
    var currentAnimationFrame = 0
    @Published
    var position = CGPoint()
    @Published
    var isShowing = false
    var frameSize: CGSize = CGSize()
    @Published
    var currentFrame:ImageResource = ImageResource(name: "", bundle: .main)

    var ladderHeight = 0.0
    var ladderStep = 0.0

    init(xPos: Int, yPos: Int, frameSize: CGSize) {
        self.xPos = xPos
        self.yPos = yPos
        self.frameSize = frameSize
        position = calcPositionFromScreen()
    }
    
    func setPosition(xPos:Int, yPos:Int) {
        self.xPos = xPos
        self.yPos = yPos
        position = calcPositionFromScreen()
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
        }
    }
    
    func setPosition() {
        position = calcPositionFromScreen()
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
        }
    }
    
    func calcPositionForAsset(xPos:Int, yPos:Int) -> CGPoint  {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            let assetOffsetAtPosition = resolvedInstance.screenData[yPos][xPos].assetOffset
            return CGPoint(x: Double(xPos) * resolvedInstance.assetDimention + (resolvedInstance.assetDimention / 2), y: Double(yPos) * resolvedInstance.assetDimention - (resolvedInstance.assetOffset * assetOffsetAtPosition) + 80)
        }
        return CGPoint()
    }
    
    func calcPositionFromScreen(xPos:Int,yPos:Int,frameSize:CGSize) -> CGPoint {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            var position = calcPositionForAsset(xPos: xPos, yPos: yPos)
            position.y -= (frameSize.height / 2) + (resolvedInstance.assetDimention / 2)
            return position
        }
        return CGPoint()
    }
    
    func calcPositionFromScreen() -> CGPoint {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            var position = calcPositionForAsset()
            position.y -= (frameSize.height / 2) + (resolvedInstance.assetDimention / 2)
            return position
        }
        return CGPoint()
    }
    
    func calcPositionForAsset() -> CGPoint  {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            let assetOffsetAtPosition = resolvedInstance.screenData[yPos][xPos].assetOffset
            return CGPoint(x: Double(xPos) * resolvedInstance.assetDimention + (resolvedInstance.assetDimention / 2), y: Double(yPos) * resolvedInstance.assetDimention - (resolvedInstance.assetOffset * assetOffsetAtPosition) + 80)
        }
        return CGPoint()
    }
    
    func isBlankAbove() -> Bool {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            if resolvedInstance.screenData[yPos - 1][xPos].assetType == .blank {
                return true
            }
        }
        return false
    }
 
    func isBlankRight() -> Bool {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            guard xPos < resolvedInstance.screenDimentionX - 1 else { return true }
            return resolvedInstance.screenData[yPos][xPos+1].assetBlank()
        }
        return false
    }

    func isBlankLeft() -> Bool {
        guard xPos > 1 else { return true }
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            return resolvedInstance.screenData[yPos][xPos-1].assetBlank()
        }
        return false
    }

    
    func isLadderAbove() -> Bool {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            if resolvedInstance.screenData[yPos - 1][xPos].assetType == .blank { return false }
            if resolvedInstance.screenData[yPos - 1][xPos].assetType == .ladder || resolvedInstance.screenData[yPos][xPos].assetType == .ladder {
                return true
            }
        }
        return false
    }
    
    func isLadderBelow() -> Bool {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            if resolvedInstance.screenData[yPos][xPos].assetType == .ladder { return true }
            if resolvedInstance.screenData[yPos][xPos].assetType == .blank { return false }
            if yPos <= resolvedInstance.screenDimentionY - 2 {
                if resolvedInstance.screenData[yPos + 1][xPos].assetType == .ladder || resolvedInstance.screenData[yPos + 1][xPos].assetType == .girder {
                    return true
                } else {
                    if resolvedInstance.screenData[yPos + 1][xPos].assetType == .girder {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func calculateLadderHeightUp() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            var yCount = 0
            while resolvedInstance.screenData[yPos-(yCount+1)][xPos].assetType == .ladder || yPos-yCount == 0 {
                yCount += 1
            }
            let endPosition = calcPositionFromScreen(xPos: xPos,yPos: yPos - (yCount + 1),frameSize: frameSize)
            ladderHeight = position.y - endPosition.y
            ladderStep = ladderHeight / Double(yCount + 1)
        }
    }
    
    func calculateLadderHeightDown() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            var yCount = 0
            while resolvedInstance.screenData[yPos+yCount+1][xPos].assetType == .ladder {
                yCount += 1
            }
            let endPosition = calcPositionFromScreen(xPos: xPos, yPos: yPos+(yCount+1),frameSize: frameSize)
            ladderHeight = endPosition.y - position.y
            ladderStep = ladderHeight / Double(yCount+1)
        }
    }

    func generateParabolicPoints(from pointA: CGPoint, to pointB: CGPoint, steps: Int = 9, angleInDegrees: CGFloat = 10) -> [CGPoint] {
        var points: [CGPoint] = []
        
        // Horizontal distance between pointA and pointB
        let dx = pointB.x - pointA.x
        
        // Height of the parabola (peak) based on 10 degrees
        let peakHeight = (dx / 2) * tan(angleInDegrees * .pi / 180)
        
        // Midpoint (vertex of the parabola)
        let midPointX = (pointA.x + pointB.x) / 2
        let vertex = CGPoint(x: midPointX, y: pointA.y - peakHeight)
        
        // Parabola equation: y = a(x - h)^2 + k
        // We need to solve for 'a' given points A and vertex
        let a = (pointA.y - vertex.y) / pow(pointA.x - vertex.x, 2)
        
        // Generate points along the parabola
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let x = pointA.x + t * (pointB.x - pointA.x)
            let y = a * pow(x - vertex.x, 2) + vertex.y
            points.append(CGPoint(x: x, y: y))
        }        
        return points
    }
}
