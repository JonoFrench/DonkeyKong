//
//  FireBlob.swift
//  DonkeyKong
//
//  Created by Jonathan French on 20.08.24.
//

import Foundation
import SwiftUI

enum FireBlobColors {
    case red,blue
}

enum FireBlobState {
    case sitting,hopping,moving
}

enum FireBlobDirection {
    case left,right,up,down,still
}


final class FireBlobArray: ObservableObject {
    @Published var fireblob: [FireBlob] = []
}


final class FireBlob: SwiftUISprite,Animatable, ObservableObject {
    static var animateFrames: Int = 9
    var animateCounter: Int = 0
    
    let moveFrames = 4
    var speed = 4
    var moveCounter = 0
    var speedCounter = 0
    var dropHeight = 0.0
    var dropStep = 0.0
    var dropCount = 0
    var color:FireBlobColors = .red
    var state:FireBlobState = .sitting
    var direction:FireBlobDirection = .still
    var fireBlobs:[ImageResource] = [ImageResource(name: "FireBlob1", bundle: .main),ImageResource(name: "FireBlob2", bundle: .main),ImageResource(name: "FireBlob3", bundle: .main)]
    var blueBlobs:[ImageResource] = [ImageResource(name: "FireBlue1", bundle: .main),ImageResource(name: "FireBlue2", bundle: .main),ImageResource(name: "FireBlue3", bundle: .main)]
    var hoppingPoints = [CGPoint]()
    var hoppingCount = 0
    
    override init(xPos: Int, yPos: Int, frameSize: CGSize) {
        super.init(xPos: xPos, yPos: yPos, frameSize: frameSize)
        let finishHop = calcPositionFromScreen(xPos: 7,yPos: 27,frameSize: frameSize)
        hoppingPoints = generateHoppingPoints(from: position, to: finishHop)
        currentFrame = ImageResource(name: "FireBlob1", bundle: .main)
        color = .red
        state = .sitting
        isShowing = true
    }
    
    func animate() {
        animateCounter += 1
        if animateCounter == FireBlob.animateFrames {
            if color == .red {
                currentFrame = fireBlobs[currentAnimationFrame]
            } else {
                currentFrame = blueBlobs[currentAnimationFrame]
            }
            currentAnimationFrame += 1
            if currentAnimationFrame == 3 {
                currentAnimationFrame = 0
            }
            animateCounter = 0
        }
    }
    
    ///Fireblob hops out of oil drum
    func hop(){
        position = hoppingPoints[hoppingCount]
        hoppingCount += 1
        if hoppingCount == hoppingPoints.count {
            state = .sitting
            color = .blue
            direction = .right
            xPos = 7
            yPos = 27
        }
        updateScreenArray()
    }
    
    func move() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            speedCounter += 1
            if speedCounter == speed {
                speedCounter = 0
                moveCounter += 1
                
                ///Move left or right
                if direction == .right {
                    position.x += resolvedInstance.assetDimention / CGFloat(moveFrames)
                } else if direction == .left  {
                    position.x -= resolvedInstance.assetDimention / CGFloat(moveFrames)
                }
                ///Move down
                if direction == .down {
                    position.y += dropStep / CGFloat(moveFrames)
                }
                
                ///Move up
                if direction == .up {
                    position.y -= dropStep / CGFloat(moveFrames)
                }
                ///Next x/y position
                if moveCounter == moveFrames {
                    moveCounter = 0
                    if direction == .right {
                        if currentHeightOffset != resolvedInstance.screenData[yPos][xPos+1].assetOffset {
                            if currentHeightOffset > resolvedInstance.screenData[yPos][xPos+1].assetOffset {
                                position.y += resolvedInstance.assetOffset
                            } else {
                                position.y -= resolvedInstance.assetOffset
                            }
                        }
                        xPos += 1
                        currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                        
                        if xPos == 29 {
                            direction = .left
                        }
                    } else if direction == .left {
                        
                        if currentHeightOffset != resolvedInstance.screenData[yPos][xPos-1].assetOffset {
                            if currentHeightOffset > resolvedInstance.screenData[yPos][xPos-1].assetOffset {
                                position.y += resolvedInstance.assetOffset
                            } else {
                                position.y -= resolvedInstance.assetOffset
                            }
                        }
                        
                        xPos -= 1
                        currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                        if xPos == 0 {
                            direction = .right
                        }
                    }
                }
                updateScreenArray()
            }
        }
    }
    
    private func updateScreenArray() {
        if let resolvedInstance: FireBlobArray = ServiceLocator.shared.resolve() {
            resolvedInstance.objectWillChange.send()
        }
    }
    
    
    func generateHoppingPoints(from pointA: CGPoint, to pointB: CGPoint, steps: Int = 30, angleInDegrees: CGFloat = 50) -> [CGPoint] {
        var points: [CGPoint] = []
        
        // Horizontal distance between pointA and pointB
        let dx = pointB.x - pointA.x
        
        // Calculate the height at the peak using the angle
        let peakHeight = abs(dx / 2) * tan(angleInDegrees * .pi / 180)
        
        // Midpoint between A and B
        let midPointX = (pointA.x + pointB.x) / 2
        let midPointY = min(pointA.y, pointB.y) - peakHeight
        
        // Vertex form of the parabola: y = a(x - h)^2 + k
        let h = midPointX
        let k = midPointY
        
        // Calculate coefficient 'a' using pointA
        let a = (pointA.y - k) / pow(pointA.x - h, 2)
        
        // Generate points along the parabola
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let x = pointA.x + t * dx
            let y = a * pow(x - h, 2) + k
            points.append(CGPoint(x: x, y: y))
        }
        
        // Correct the final point to be exactly pointB
        points[steps] = pointB
        
        return points
    }
    
}
