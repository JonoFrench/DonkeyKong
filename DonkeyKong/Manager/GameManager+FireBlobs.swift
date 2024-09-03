//
//  GameManager+FireBlobs.swift
//  DonkeyKong
//
//  Created by Jonathan French on 27.08.24.
//

import Foundation

/// FireBlob functionality

extension GameManager {
    
    func addfireBlob() {
        let fireBlob = FireBlob(xPos: 4, yPos: 25, frameSize: CGSize(width: 24, height:  24))
        fireBlobArray.fireblob.append(fireBlob)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [fireBlob] in
            fireBlob.state = .hopping
        }
    }
    
    func addFireBlob(xPos:Int, yPos: Int, state:FireBlobState) {
        let fireBlob = FireBlob(xPos: xPos, yPos: yPos, frameSize: CGSize(width: 24, height:  24))
        fireBlob.state = state
        fireBlob.direction = .right
        fireBlobArray.fireblob.append(fireBlob)
    }
    
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
    
    func addPiesLevel2() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [self] in
            addRightSidePie(pos: .bottom)
        }
        swapConveyorDirection()
    }
    
    func swapConveyorDirection() {
        if gameState == .playing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) { [self] in
                if pieArray.direction == .left {
                    pieArray.direction = .right
                } else {
                    pieArray.direction = .left
                }
                swapConveyorDirection()
            }
        }
    }
    func addLeftSidePie(pos:ConveyorPos){
        pieArray.pies.append(Pie(xPos: 0, yPos: pos.rawValue, direction: .right))
    }
    func addRightSidePie(pos:ConveyorPos){
        pieArray.pies.append(Pie(xPos: 29, yPos: pos.rawValue, direction: .left))
    }

    func addPies() {
        if Int.random(in: 0...200) == 3 {
            if Int.random(in: 0...10) <= 6 {
                if pieArray.direction == .left {
                    addRightSidePie(pos: .bottom)
                } else {
                    addLeftSidePie(pos: .bottom)
                }
            } else {
                if Int.random(in: 0...1) == 1 {
                    addRightSidePie(pos: .top)
                } else {
                    addLeftSidePie(pos: .top)
                }
            }
        }
    }
    
    func explodeFireBlob(fireBlob:FireBlob){
        explosion.xPos = fireBlob.xPos
        explosion.yPos = fireBlob.yPos
        explosion.position = fireBlob.position
        explosion.currentFrame = explosion.explosions[0]
        explosion.animateCounter = 0
        hasExplosion = true
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
                explodeFireBlob(fireBlob: fireBlob)
                removeFireBlob(fireBlob: fireBlob)
                pause = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                    pause = false
                }
            }
        }
    }
    
    func removeFireBlob(fireBlob:FireBlob) {
        if let index = fireBlobArray.fireblob.firstIndex(where: {$0.id == fireBlob.id}) {
            fireBlobArray.fireblob.remove(at: index)
        }
    }

    func addSpring() {
        let spring = Spring(xPos: 2 + Int.random(in: 0..<3), yPos: 7, frameSize: CGSize(width: 24, height:  24))
        springArray.springs.append(spring)
        springAdded = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            springAdded = false
        }
    }

    func removeSpring(spring:Spring) {
        if let index = springArray.springs.firstIndex(where: {$0.id == spring.id}) {
            springArray.springs.remove(at: index)
        }
    }

    func throwSpring(){
        guard springAdded == false else {return}
        if Int.random(in: 0..<100) == 25 {
            if springArray.springs.count < 3 {
                print("Adding Spring")
                addSpring()
            }
        }
    }
}
