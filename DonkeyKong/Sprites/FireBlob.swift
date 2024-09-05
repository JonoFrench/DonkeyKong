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
    
    func remove(id:UUID) {
        if let index = fireblob.firstIndex(where: {$0.id == id}) {
            fireblob.remove(at: index)
        }
    }
    
    func add(xPos:Int, yPos: Int, state:FireBlobState) {
        let fireBlob = FireBlob(xPos: xPos, yPos: yPos, frameSize: CGSize(width: 24, height:  24))
        fireBlob.state = state
        fireBlob.direction = .right
        fireblob.append(fireBlob)
    }
    /// Initial fireblobs hopping out of level 1
    func add() {
        let fireBlob = FireBlob(xPos: 4, yPos: 25, frameSize: CGSize(width: 24, height:  24))
        fireblob.append(fireBlob)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [fireBlob] in
            fireBlob.state = .hopping
        }
    }

}

final class FireBlob: SwiftUISprite,Animatable, ObservableObject {
    static var animateFrames: Int = 9
    var animateCounter: Int = 0
    
    let moveFrames = 4
    var speed = AppConstant.fireBlobSpeed
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
    var hoppingToX = 0
    var hoppingToY = 0
    var hoppingTodirection:FireBlobDirection = .still
    var hasHammer:Bool = false {
        didSet {
            color = hasHammer ? .blue : .red
        }
    }
    
    override init(xPos: Int, yPos: Int, frameSize: CGSize) {
        super.init(xPos: xPos, yPos: yPos, frameSize: frameSize)
        let finishHop = calcPositionFromScreen(xPos: 7,yPos: 27,frameSize: frameSize)
        hoppingToX = 7
        hoppingToY = 27
        hoppingTodirection = .right
        hoppingPoints = generateHoppingPoints(from: position, to: finishHop)
        currentFrame = ImageResource(name: "FireBlob1", bundle: .main)
        color = .red
        state = .sitting
        isShowing = true
    }
    
    func setHopping(xPos: Int, yPos: Int, direction:FireBlobDirection) {
        hoppingCount = 0
        hoppingToX = xPos
        hoppingToY = yPos
        hoppingTodirection = direction
        let finishHop = calcPositionFromScreen(xPos: xPos,yPos: yPos,frameSize: frameSize)
        let degrees: CGFloat = direction == .left ? -50 : 50
        hoppingPoints = generateParabolicPoints(from: position, to: finishHop, angleInDegrees: degrees)
        //hoppingPoints = generateHoppingPoints(from: position, to: finishHop)
        state = .hopping
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
    func hop(state:FireBlobState){
        position = hoppingPoints[hoppingCount]
        hoppingCount += 1
        if hoppingCount == hoppingPoints.count {
            self.state = .moving
            color = .blue
            self.direction = hoppingTodirection
            setPosition(xPos: hoppingToX, yPos: hoppingToY)
        }
        updateScreenArray()
    }
    
    func moveFrame() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            ///Move left or right
            if direction == .right {
                position.x += resolvedInstance.assetDimention / CGFloat(moveFrames)
            } else if direction == .left  {
                position.x -= resolvedInstance.assetDimention / CGFloat(moveFrames)
            }
            ///Move down
            if direction == .down {
                position.y += ladderStep / CGFloat(moveFrames)
            }
            ///Move up
            if direction == .up {
                position.y -= ladderStep / CGFloat(moveFrames)
            }
        }
    }
    
    func move() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            speedCounter += 1
            if speedCounter == speed {
                speedCounter = 0
                moveCounter += 1
                moveFrame()
                ///Next x/y position
                if moveCounter == moveFrames {
                    moveCounter = 0
//                    print("FireBlob on \(resolvedInstance.screenData[yPos][xPos].assetType) xpos \(xPos) ypos \(yPos) going \(direction)")

//                                        if Int.random(in: 0..<20) == 3 {
//                                            if direction == .right && xPos > 1 {
//                                                direction = .left
//                                            } else if direction == .left && xPos < 28 {
//                                                direction = .right
//                                            }
//                                        }


                    if direction == .right {
                        if isBlankRight() {
 //                           print("FireBlob going \(direction)  xpos \(xPos)")
                            direction = .left
                            //position.x -= resolvedInstance.assetDimention / CGFloat(moveFrames)
                            setPosition()
                            //xPos -= 1
                        } else {
                            xPos += 1
                            if currentHeightOffset != resolvedInstance.screenData[yPos][xPos].assetOffset {
                                if currentHeightOffset > resolvedInstance.screenData[yPos][xPos].assetOffset {
                                    position.y += resolvedInstance.assetOffset
                                } else {
                                    position.y -= resolvedInstance.assetOffset
                                }
                            }
                        }
                        currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset

                    } else if direction == .left {
                        if isBlankLeft() {
                            print("FireBlob going \(direction)  xpos \(xPos)")
                            direction = .right
                            //position.x += resolvedInstance.assetDimention / CGFloat(moveFrames)
                            setPosition()
                            //xPos += 1
                        } else {
                            xPos -= 1
                            if currentHeightOffset != resolvedInstance.screenData[yPos][xPos].assetOffset {
                                if currentHeightOffset > resolvedInstance.screenData[yPos][xPos].assetOffset {
                                    position.y += resolvedInstance.assetOffset
                                } else {
                                    position.y -= resolvedInstance.assetOffset
                                }
                            }

                        }
                        currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset

                        
                    } else if direction == .up {
                        if yPos != 0 {
                            yPos -= 1
                            currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                        }

                        if resolvedInstance.screenData[yPos][xPos].assetType == .girder || resolvedInstance.screenData[yPos][xPos].assetType == .conveyor {
                                if Int.random(in: 0..<2) == 1 {
                                    direction = .left
                                } else {
                                    direction = .right
                                }
                            
                        }
 
                    } else if direction == .down {
                        if yPos < resolvedInstance.screenDimentionY - 1 {
                            yPos += 1
                            currentHeightOffset = resolvedInstance.screenData[yPos][xPos].assetOffset
                        }

                        if resolvedInstance.screenData[yPos][xPos].assetType == .girder || resolvedInstance.screenData[yPos][xPos].assetType == .conveyor {
                                if Int.random(in: 0..<2) == 1 {
                                    direction = .left
                                    if xPos > 1 {
                                        if !isBlankLeft() {
                                            direction = .right
                                        }
                                    }
                                } else {
                                    direction = .right
                                    if xPos < resolvedInstance.screenDimentionX {
                                        if !isBlankRight() {
                                            direction = .left
                                        }
                                    }
                                }
                            print("FireBlob going \(direction)  xpos \(xPos)")

                        }
                    }
                    
                    if isLadderAbove() && (direction == .left || direction == .right) {
                        if yPos > 10 {
 //                           print("FireBlob lets go up?")
                            if Int.random(in: 0..<5) == 3 {
//                                print("FireBlob going up")
                                calculateLadderHeightUp()
                                direction = .up
                            }
                        }
                    }
                    
                    else if isLadderBelow() && (direction == .left || direction == .right) {
//                        print("FireBlob lets go down?")
                        if Int.random(in: 0..<5) == 3 {
//                            print("FireBlob going down")
                            calculateLadderHeightDown()
                            direction = .down
                        }
                    }

                }
                updateScreenArray()
            }
        }
    }
    
    override func isLadderAbove() -> Bool {
        guard yPos > 10 else { return false }
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            if resolvedInstance.screenData[yPos - 1][xPos].assetType == .blank && (resolvedInstance.screenData[yPos - 2][xPos].assetType == .ladder || resolvedInstance.screenData[yPos - 2][xPos].assetType == .blankLadder) { return true }
            if resolvedInstance.screenData[yPos - 1][xPos].assetType == .ladder || resolvedInstance.screenData[yPos][xPos].assetType == .ladder || resolvedInstance.screenData[yPos - 1][xPos].assetType == .blankLadder || resolvedInstance.screenData[yPos][xPos].assetType == .blankLadder {
                return true
            }
        }
        return false
    }

    override func isLadderBelow() -> Bool {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            guard yPos < resolvedInstance.screenDimentionY - 2 else { return false }
            if resolvedInstance.screenData[yPos + 1][xPos].assetType == .blank && (resolvedInstance.screenData[yPos + 2][xPos].assetType == .ladder || resolvedInstance.screenData[yPos + 2][xPos].assetType == .blankLadder) { return true }
            if resolvedInstance.screenData[yPos + 1][xPos].assetType == .ladder || resolvedInstance.screenData[yPos][xPos].assetType == .ladder || resolvedInstance.screenData[yPos + 1][xPos].assetType == .blankLadder || resolvedInstance.screenData[yPos][xPos].assetType == .blankLadder {
                return true
            }
        }
        return false
    }
    
    private func updateScreenArray() {
        if let resolvedInstance: FireBlobArray = ServiceLocator.shared.resolve() {
            resolvedInstance.objectWillChange.send()
        }
    }
    
    override func calculateLadderHeightUp() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            let endPosition = calcPositionFromScreen(xPos: xPos, yPos: yPos-4,frameSize: frameSize)
            ladderHeight = position.y - endPosition.y
            ladderStep = ladderHeight / 4.0
            currentHeightOffset = resolvedInstance.screenData[yPos-4][xPos].assetOffset
        }
    }

    override func calculateLadderHeightDown() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            let endPosition = calcPositionFromScreen(xPos: xPos, yPos: yPos+4,frameSize: frameSize)
            ladderHeight = endPosition.y - position.y
            ladderStep = ladderHeight / 4.0
            currentHeightOffset = resolvedInstance.screenData[yPos+4][xPos].assetOffset
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
