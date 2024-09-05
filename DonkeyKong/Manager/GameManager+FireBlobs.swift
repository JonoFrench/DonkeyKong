//
//  GameManager+FireBlobs.swift
//  DonkeyKong
//
//  Created by Jonathan French on 27.08.24.
//

import Foundation

/// FireBlob functionality

extension GameManager {
    
    func startMovingFireBlob(fireBlob:FireBlob) {
        if Int.random(in: 0..<300) == 3 {
            if Int.random(in: 0...1) == 1 {
                fireBlob.setHopping(xPos: fireBlob.xPos - 3, yPos: fireBlob.yPos,direction: .left)
            } else {
                fireBlob.setHopping(xPos: fireBlob.xPos + 3, yPos: fireBlob.yPos,direction: .right)
            }
        }
    }
    
    func addLevel4FireBlobs() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [self] in
            let fireBlob = FireBlob(xPos: 1, yPos: 27, frameSize: CGSize(width: 24, height:  24))
            fireBlob.state = .moving
            fireBlob.direction = .right
            fireBlobArray.fireblob.append(fireBlob)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [self] in
                let fireBlob = FireBlob(xPos: 1, yPos: 22, frameSize: CGSize(width: 24, height:  24))
                fireBlob.state = .moving
                fireBlob.direction = .right
                fireBlobArray.fireblob.append(fireBlob)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [self] in
                    let fireBlob = FireBlob(xPos: 1, yPos: 27, frameSize: CGSize(width: 24, height:  24))
                    fireBlob.state = .moving
                    fireBlob.direction = .right
                    fireBlobArray.fireblob.append(fireBlob)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [self] in
                    let fireBlob = FireBlob(xPos: 27, yPos: 22, frameSize: CGSize(width: 24, height:  24))
                    fireBlob.state = .moving
                    fireBlob.direction = .left
                    fireBlobArray.fireblob.append(fireBlob)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [self] in
                        let fireBlob = FireBlob(xPos: 27, yPos: 27, frameSize: CGSize(width: 24, height:  24))
                        fireBlob.state = .moving
                        fireBlob.direction = .left
                        fireBlobArray.fireblob.append(fireBlob)
                    }
                }
            }
        }
    }
    
    func swapConveyorDirection() {
        if gameState == .playing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) { [self] in
                pieArray.direction = pieArray.direction == .right ? .left : .right
                swapConveyorDirection()
            }
        }
    }
    
    func addPies() {
        guard pieArray.pies.count < 10 else {return} /// don't want too many
        if Int.random(in: 0...200) == 3 {
            if Int.random(in: 0...10) <= 6 {
                if pieArray.direction == .right {
                    pieArray.add(direction: .right, pos: .bottom)
                } else {
                    pieArray.add(direction: .left, pos: .bottom)
                }
            } else {
                if Int.random(in: 0...1) == 1 {
                    pieArray.add(direction: .left, pos: .top)
                } else {
                    pieArray.add(direction: .right, pos: .bottom)
                }
            }
        }
    }
     
    func explode(sprite:SwiftUISprite){
        explosion.xPos = sprite.xPos
        explosion.yPos = sprite.yPos
        explosion.position = sprite.position
        explosion.currentFrame = explosion.explosions[0]
        explosion.animateCounter = 0
        gameScreen.hasExplosion = true
    }
    
    func checkFireBlobHit(fireBlob:FireBlob) {
        if jumpMan.hasHammer {
            let hammerOffset = jumpMan.frameSize.width / 4
            var hammerPos = jumpMan.position
            hammerPos.y += hammerOffset
            if jumpMan.facing == .left {
                hammerPos.x -= hammerOffset
            } else {
                hammerPos.x += hammerOffset
            }
            
            if circlesIntersect(center1: hammerPos, diameter1: jumpMan.frameSize.width / 4, center2: fireBlob.position, diameter2: fireBlob.frameSize.width / 2) {
                soundFX.hammerSound()
                explode(sprite: fireBlob)
                fireBlobArray.remove(id: fireBlob.id)
                gameScreen.pause = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                    gameScreen.pause = false
                }
            }
        }
    }
    
    func checkFireBlobJumped(fireBlob:FireBlob) {
        guard !gameScreen.hasPoints && jumpMan.isJumping  else { return }
        var fireblobPos = fireBlob.position
        fireblobPos.y -= fireBlob.frameSize.height
        
        if circlesIntersect(center1: jumpMan.position, diameter1: jumpMan.frameSize.width, center2: fireblobPos, diameter2: fireBlob.frameSize.width / 2) {
            addPoints(value: 100, position: fireBlob.position)
            soundFX.barrelJumpSound()
        }
    }
      
    func checkPieHit(pie:Pie) {
        if jumpMan.hasHammer {
            let hammerOffset = jumpMan.frameSize.width / 4
            var hammerPos = jumpMan.position
            hammerPos.y += hammerOffset
            if jumpMan.facing == .left {
                hammerPos.x -= hammerOffset
            } else {
                hammerPos.x += hammerOffset
            }
            
            if circlesIntersect(center1: hammerPos, diameter1: jumpMan.frameSize.width / 4, center2: pie.position, diameter2: pie.frameSize.width / 2) {
                soundFX.hammerSound()
                explode(sprite: pie)
                pieArray.remove(id: pie.id)
                gameScreen.pause = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                    gameScreen.pause = false
                }
            }
        }
    }
    
    func checkPieJumped(pie:Pie) {
        guard !gameScreen.hasPoints && jumpMan.isJumping  else { return }
        var piePos = pie.position
        piePos.y -= pie.frameSize.height
        
        if circlesIntersect(center1: jumpMan.position, diameter1: jumpMan.frameSize.width, center2: piePos, diameter2: pie.frameSize.width / 2) {
            addPoints(value: 300, position: pie.position)
            soundFX.barrelJumpSound()
        }
    }
    
    func throwSpring(){
        guard springArray.springAdded == false && springArray.springs.count < 3 else {return}
        if Int.random(in: 0..<100) == 25 {
            springArray.add()
        }
    }
}
