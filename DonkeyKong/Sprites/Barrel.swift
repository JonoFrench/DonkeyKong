//
//  Barrel.swift
//  DonkeyKong
//
//  Created by Jonathan French on 20.08.24.
//

import Foundation
import SwiftUI

enum BarrelDirection {
    case left,right,down,leftDown,rightDown
}

enum BarrelColor {
    case orange,blue
}

final class BarrelArray: ObservableObject {
    @Published var barrels: [Barrel] = []
    static let rollingSize = CGSize(width: 16, height:  16)
    static let thrownSize = CGSize(width: 24, height:  24)
    static let rollingX = 9
    static let rollingY = 7
    static let thrownX = 6
    static let thrownY = 5
    
    func remove(id:UUID) {
        if let index = barrels.firstIndex(where: {$0.id == id}) {
            barrels.remove(at: index)
        }
    }
    
    func add(thrown:Bool) {
        if !thrown {
            let barrel = Barrel(xPos: BarrelArray.rollingX, yPos: BarrelArray.rollingY, frameSize: BarrelArray.rollingSize)
            barrel.isThrown = false
            barrels.append(barrel)
        } else {
            let barrel = Barrel(xPos: BarrelArray.thrownX, yPos: BarrelArray.thrownY, frameSize: BarrelArray.thrownSize)
            barrel.isThrown = true
            barrel.direction = .down
            barrel.color = .blue
            barrels.append(barrel)
        }
    }
}

final class Barrel:SwiftUISprite,Animatable, Moveable, ObservableObject {
    static var animateFrames: Int = 9
    static var speed:Int = AppConstant.barrelSpeed
    var animateCounter: Int = 0
    var speedCounter:Int = 0
    
    let moveFrames = 4
    var moveCounter = 0
    var direction:BarrelDirection = .right
    var nextDirection:BarrelDirection = .left
    var color: BarrelColor = .orange
    var dropHeight = 0.0
    var dropStep = 0.0
    var dropCount = 0
    var orangeBarrels:[ImageResource] = [ImageResource(name: "Barrel1", bundle: .main),ImageResource(name: "Barrel2", bundle: .main),ImageResource(name: "Barrel3", bundle: .main),ImageResource(name: "Barrel4", bundle: .main)]
    var blueBarrels:[ImageResource] = [ImageResource(name: "BarrelBlue1", bundle: .main),ImageResource(name: "BarrelBlue2", bundle: .main),ImageResource(name: "BarrelBlue3", bundle: .main),ImageResource(name: "BarrelBlue4", bundle: .main)]
    var orangeDroppingBarrels:[ImageResource] = [ImageResource(name: "BarrelDown", bundle: .main),ImageResource(name: "BarrelDown", bundle: .main),ImageResource(name: "BarrelDown", bundle: .main),ImageResource(name: "BarrelDown", bundle: .main)]
    var blueDroppingBarrels:[ImageResource] = [ImageResource(name: "BarrelBlueDown", bundle: .main),ImageResource(name: "BarrelBlueDown2", bundle: .main),ImageResource(name: "BarrelBlueDown", bundle: .main),ImageResource(name: "BarrelBlueDown2", bundle: .main)]
    
    var droppingDown = false
    var isThrown = false
    var wasThrown = false
    @Published
    var toFireBlob = false
    
    override init(xPos: Int, yPos: Int, frameSize: CGSize) {
        super.init(xPos: xPos, yPos: yPos, frameSize: frameSize)
        currentFrame = ImageResource(name: "Barrel1", bundle: .main)
        isShowing = true
        if Int.random(in: 0..<6) == 3 {
            color = .blue
        }
    }
    
    func animate() {
        animateCounter += 1
        if animateCounter == Barrel.animateFrames {
            if color == .blue {
                if droppingDown || isThrown {
                    currentFrame = blueDroppingBarrels[currentAnimationFrame]
                } else {
                    currentFrame = blueBarrels[currentAnimationFrame]
                }
            } else {
                if droppingDown {
                    currentFrame = orangeDroppingBarrels[currentAnimationFrame]
                } else {
                    currentFrame = orangeBarrels[currentAnimationFrame]
                }
            }
            currentAnimationFrame += 1
            if currentAnimationFrame == 4 {
                currentAnimationFrame = 0
            }
            animateCounter = 0
        }
    }
    
    func move() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            speedCounter += 1
            if speedCounter == Barrel.speed {
                speedCounter = 0
                moveCounter += 1
/// Thrown Barrel
                if isThrown {
                    position.y += resolvedInstance.assetDimention / CGFloat(moveFrames)
                    
                    if moveCounter == moveFrames {
                        moveCounter = 0
                        yPos += 1
                    }
                    if yPos == 27 {
                        direction = .left
                        isThrown = false
                        wasThrown = true
                    }
                } else {
/// Rolled barrel.
                    ///Move left or right
                    if direction == .right || direction == .rightDown {
                        position.x += resolvedInstance.assetDimention / CGFloat(moveFrames)
                    } else if direction == .left || direction == .leftDown {
                        position.x -= resolvedInstance.assetDimention / CGFloat(moveFrames)
                    }
                    ///Move down
                    if direction == .down || direction == .rightDown || direction == .leftDown {
                        position.y += dropStep / CGFloat(moveFrames)
                    }
                    ///Next x/y position
                    if moveCounter == moveFrames {
                        moveCounter = 0
                        if direction == .left {
                            if currentHeightOffset != resolvedInstance.screenData[yPos][xPos-1].assetOffset {
                                position.y += resolvedInstance.assetOffset
                                currentHeightOffset = resolvedInstance.screenData[yPos][xPos-1].assetOffset
                            }
                        } else if direction == .right {
                            if currentHeightOffset != resolvedInstance.screenData[yPos][xPos+1].assetOffset {
                                position.y += resolvedInstance.assetOffset
                                currentHeightOffset = resolvedInstance.screenData[yPos][xPos+1].assetOffset
                            }
                        }
                        ///Check for drop
                        if direction == .left || direction == .right {
                            if checkLadderDrop() {
                                calculateDropHeight()
                                droppingDown = true
                                if direction == .right {
                                    direction = .down
                                    nextDirection = .left
                                } else if direction == .left {
                                    direction = .down
                                    nextDirection = .right
                                }
                                return
                            }
                            if checkDrop() {
                                calculateDropHeight()
                                if direction == .right {
                                    direction = .rightDown
                                    nextDirection = .left
                                } else if direction == .left {
                                    direction = .leftDown
                                    nextDirection = .right
                                }
                                return
                            }
                        }
                        
                        if direction == .down {
                            dropCount += 1
                            yPos += 1
                        } else if direction == .right {
                            xPos += 1
                        } else if direction == .left {
                            xPos -= 1
                        } else if direction == .rightDown {
                            xPos += 1
                            yPos += 1
                            dropCount += 1
                            direction = .down
                        } else if direction == .leftDown {
                            xPos -= 1
                            yPos += 1
                            dropCount += 1
                            direction = .down
                        }
                        if dropCount == 4 {
                            direction = nextDirection
                            dropCount = 0
                            droppingDown = false
                        }
                        if xPos == 3 && yPos == 27 {
                            let barrelID:[String: UUID] = ["id": self.id]
                            if wasThrown {
                                NotificationCenter.default.post(name: .notificationBarrelToFireblob, object: nil, userInfo: barrelID)
                            } else {
                                NotificationCenter.default.post(name: .notificationRemoveBarrel, object: nil, userInfo: barrelID)
                            }
                        }
                    }
                }
                updateScreenArray()
            }
        }
    }
      
    private func updateScreenArray() {
        if let resolvedInstance: BarrelArray = ServiceLocator.shared.resolve() {
            resolvedInstance.objectWillChange.send()
        }
    }
    
    /// If barrel goes over ladder 1 in 3 of it dropping down
    private func checkLadderDrop() ->Bool {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            if yPos < 27 {
                
                if direction == .left {
                    if resolvedInstance.screenData[yPos+1][xPos].assetType == .ladder {
                        if Int.random(in: 0..<3) == 2 { return true }
                    }
                } else {
                    if resolvedInstance.screenData[yPos+1][xPos+1].assetType == .ladder {
                        if Int.random(in: 0..<3) == 2 { return true }
                    }
                }
            }
        }
        return false
    }
    
    private func checkDrop() ->Bool {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            if direction == .left {
                if resolvedInstance.screenData[yPos][xPos - 1].assetType == .blank {return true}
            } else {
                if resolvedInstance.screenData[yPos][xPos + 1].assetType == .blank {return true}
            }
        }
        return false
    }
    
    private func calculateDropHeight() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            let endPosition = calcPositionFromScreen(xPos: xPos, yPos: yPos+4,frameSize: frameSize)
            dropHeight = endPosition.y - position.y
            dropStep = dropHeight / 4.0
            currentHeightOffset = resolvedInstance.screenData[yPos+4][xPos].assetOffset
        }
    }
}
