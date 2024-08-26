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
            if Int.random(in: 0..<10) == 5 {
                throwBarrelDown()
            } else {
                
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
    }
    
    func throwBarrelDown(){
        kong.isThrowing = true
        kong.currentFrame = kong.kongLeft
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            kong.currentFrame = kong.kongFacing
            addBarrelDown()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                kong.currentFrame = kong.kongFacing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                    kong.isThrowing = false
                }
            }
        }
        
    }
    
    func addBarrel() {
        let barrel = Barrel()
        if Int.random(in: 0..<6) == 3 {
            barrel.color = .blue
        }
        barrel.isThrown = false
        barrel.xPos = 9
        barrel.yPos = 7
        barrel.currentHeightOffset = screenData[barrel.yPos][barrel.xPos].assetOffset
        barrel.position = calcPositionFromScreen(xPos: barrel.xPos,yPos: barrel.yPos,frameSize: barrel.frameSize)
        barrelArray.barrels.append(barrel)
    }
    
    func addBarrelDown() {
        let barrel = Barrel()
        barrel.isThrown = true
        barrel.direction = .down
        barrel.color = .blue
        barrel.xPos = 6
        barrel.yPos = 5
        barrel.frameSize = CGSize(width: 24, height:  24)
        barrel.currentHeightOffset = screenData[barrel.yPos][barrel.xPos].assetOffset
        barrel.position = calcPositionFromScreen(xPos: barrel.xPos,yPos: barrel.yPos,frameSize: barrel.frameSize)
        barrelArray.barrels.append(barrel)
    }

    func moveThrownBarrel(barrel:Barrel) {
        barrel.speedCounter += 1
        if barrel.speedCounter == barrel.speed {
            barrel.speedCounter = 0
            barrel.moveCounter += 1
            barrel.position.y += self.assetDimention / CGFloat(barrel.moveFrames)

            if barrel.moveCounter == barrel.moveFrames {
                barrel.moveCounter = 0
                barrel.yPos += 1
            }
            
            if barrel.yPos == 27 {

                barrel.direction = .left
                barrel.isThrown = false
                //removeBarrel(barrel: barrel)
            }
            
            self.barrelArray.objectWillChange.send()
        }
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
                    
                    if checkLadderDrop(barrel: barrel) {
                        print("Barrel Ladder Drop")
                        calculateDropHeight(barrel: barrel)
                        barrel.droppingDown = true
                        if barrel.direction == .right {
                            barrel.direction = .down
                            barrel.nextDirection = .left
                        } else if barrel.direction == .left {
                            barrel.direction = .down
                            barrel.nextDirection = .right
                        }
                        return
                    }
                    
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
                    barrel.droppingDown = false
                }
                if barrel.xPos == 1 && barrel.yPos == 27 {
                    if !hasExplosion {
                        explodeBarrel(barrel: barrel)
                    }
                    removeBarrel(barrel: barrel)
                }
                checkBarrelHit(barrel:barrel)
            }
            self.barrelArray.objectWillChange.send()
        }
    }
    
    func explodeBarrel(barrel:Barrel){
        explosion.xPos = barrel.xPos
        explosion.yPos = barrel.yPos
        explosion.position = barrel.position
        explosion.currentFrame = explosion.explosions[0]
        explosion.animateCounter = 0
        hasExplosion = true
    }
    
    /// If barrel goes over ladder 1 in 3 of it dropping down
    func checkLadderDrop(barrel:Barrel) ->Bool {
        if barrel.yPos < 27 {
            
            if barrel.direction == .left {
                if self.screenData[barrel.yPos+1][barrel.xPos].assetType == .ladder {
                    print("Over ladder left")
                    if Int.random(in: 0..<3) == 2 { return true }
                }
            } else {
                if self.screenData[barrel.yPos+1][barrel.xPos+1].assetType == .ladder {
                    print("Over ladder right")
                    if Int.random(in: 0..<3) == 2 { return true }
                }
            }
        }
        return false
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
    
    func checkBarrelHit(barrel:Barrel) {
            if jumpMan.hasHammer {
            let hammerOffset = jumpMan.frameSize.width / 4
            var hammerPos = jumpMan.position
                hammerPos.y += hammerOffset
            if jumpMan.facing == .left {
                hammerPos.x -= hammerOffset
            } else {
                hammerPos.x += hammerOffset
            }
            
                if circlesIntersect(center1: hammerPos, diameter1: jumpMan.frameSize.width / 4, center2: barrel.position, diameter2: barrel.frameSize.width / 2) {
                    soundFX.hammerSound()
                    explodeBarrel(barrel: barrel)
                    removeBarrel(barrel: barrel)
                    pause = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                        pause = false
                    }
                }
            }
        }
    
}
