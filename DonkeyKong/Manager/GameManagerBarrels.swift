//
//  GameManagerBarrels.swift
//  DonkeyKong
//
//  Created by Jonathan French on 21.08.24.
//

import Foundation

extension GameManager {
    
    func throwBarrel(){
        if Int.random(in: 0..<300) == 25 && !kong.isThrowing {
            kong.isThrowing = true
            kong.currentFrame = kong.kongLeft
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                kong.currentFrame = kong.kongRight
                addBarrel()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    kong.currentFrame = kong.kongFacing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                        kong.isThrowing = false
                    }
                }
            }
        }
    }
    
    func addBarrel() {
        let barrel = Barrel()
        barrel.xPos = 9
        barrel.yPos = 7
        barrel.currentHeightOffset = screenData[barrel.yPos][barrel.xPos].assetOffset
        barrel.position = calcPositionFromScreen(xPos: barrel.xPos,yPos: barrel.yPos,frameSize: barrel.frameSize)
        barrelArray.barrels.append(barrel)
    }
    
    func moveBarrel(barrel:Barrel) {
        barrel.speedCounter += 1
        if barrel.speedCounter == barrel.speed {
            barrel.speedCounter = 0
            barrel.moveCounter += 1
            ///Move left or right
            if barrel.direction == .right || barrel.direction == .rightDown {
                barrel.position.x += self.assetDimention / CGFloat(barrel.moveFrames)
            } else if barrel.direction == .left || barrel.direction == .leftDown {
                barrel.position.x -= self.assetDimention / CGFloat(barrel.moveFrames)
            }
            ///Move down
            if barrel.direction == .down || barrel.direction == .rightDown || barrel.direction == .leftDown {
                barrel.position.y += barrel.dropStep / CGFloat(barrel.moveFrames)
            }
            ///Next x/y position
            if barrel.moveCounter == barrel.moveFrames {
                barrel.moveCounter = 0
                if barrel.direction == .left {
                    if barrel.currentHeightOffset != self.screenData[barrel.yPos][barrel.xPos-1].assetOffset {
                        barrel.position.y += self.assetOffset
                        barrel.currentHeightOffset = self.screenData[barrel.yPos][barrel.xPos-1].assetOffset
                    }
                } else if barrel.direction == .right {
                    if barrel.currentHeightOffset != self.screenData[barrel.yPos][barrel.xPos+1].assetOffset {
                        barrel.position.y += self.assetOffset
                        barrel.currentHeightOffset = self.screenData[barrel.yPos][barrel.xPos+1].assetOffset
                    }
                }
                
                ///Check for drop
                if barrel.direction == .left || barrel.direction == .right {
                    if checkDrop(barrel: barrel) {
                        print("Barrel Drop")
                        calculateDropHeight(barrel: barrel)
                        
                        if barrel.direction == .right {
                            barrel.direction = .rightDown
                            barrel.nextDirection = .left
                        } else if barrel.direction == .left {
                            barrel.direction = .leftDown
                            barrel.nextDirection = .right
                        }
                        return
                    }
                }
                
                if barrel.direction == .down {
                    barrel.dropCount += 1
                    barrel.yPos += 1
                } else if barrel.direction == .right {
                    barrel.xPos += 1
                } else if barrel.direction == .left {
                    barrel.xPos -= 1
                } else if barrel.direction == .rightDown {
                    barrel.xPos += 1
                    barrel.yPos += 1
                    barrel.dropCount += 1
                    barrel.direction = .down
                } else if barrel.direction == .leftDown {
                    barrel.xPos -= 1
                    barrel.yPos += 1
                    barrel.dropCount += 1
                    barrel.direction = .down
                }
                if barrel.dropCount == 4 {
                    barrel.direction = barrel.nextDirection
                    barrel.dropCount = 0
                }
                if barrel.xPos == 0 && barrel.yPos == 27 {
                    removeBarrel(barrel: barrel)
                }
            }
            self.barrelArray.objectWillChange.send()
        }
    }
    
    func checkDrop(barrel:Barrel) ->Bool {
        if barrel.direction == .left {
            if self.screenData[barrel.yPos][barrel.xPos - 1].assetType == .blank {return true}
        } else {
            if self.screenData[barrel.yPos][barrel.xPos + 1].assetType == .blank {return true}
        }
        return false
    }
    
    func calculateDropHeight(barrel:Barrel) {
        let endPosition = calcPositionFromScreen(xPos: barrel.xPos, yPos: barrel.yPos+4,frameSize: barrel.frameSize)
        barrel.dropHeight = endPosition.y - barrel.position.y
        barrel.dropStep = barrel.dropHeight / 4.0
        barrel.currentHeightOffset = self.screenData[barrel.yPos+4][barrel.xPos].assetOffset
    }
    
    func removeBarrel(barrel:Barrel) {
        if let index = barrelArray.barrels.firstIndex(where: {$0.id == barrel.id}) {
            barrelArray.barrels.remove(at: index)
        }
        
    }
}
