//
//  GameManager+Barrels.swift
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
            addBarrelThrown()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                kong.currentFrame = kong.kongFacing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                    kong.isThrowing = false
                }
            }
        }
    }
    
    func addBarrel() {
        let barrel = Barrel(xPos: 9, yPos: 7, frameSize: CGSize(width: 16, height:  16))
        barrel.isThrown = false
        barrelArray.barrels.append(barrel)
    }
    
    func addBarrelThrown() {
        let barrel = Barrel(xPos: 6, yPos: 5, frameSize: CGSize(width: 24, height:  24))
        barrel.isThrown = true
        barrel.direction = .down
        barrel.color = .blue
        barrelArray.barrels.append(barrel)
    }
    
    func explode(atPosition:CGPoint){
        explosion.position = atPosition
        explosion.currentFrame = explosion.explosions[0]
        explosion.animateCounter = 0
        hasExplosion = true
    }
    
    func removeBarrel(id:UUID) {
        if let index = barrelArray.barrels.firstIndex(where: {$0.id == id}) {
            barrelArray.barrels.remove(at: index)
        }
    }
 
    func removePie(id:UUID) {
        if let index = pieArray.pies.firstIndex(where: {$0.id == id}) {
            pieArray.pies.remove(at: index)
        }
    }

    func checkBarrelHit(barrel:Barrel) {
        if jumpMan.hasHammer && jumpMan.hammerDown[jumpMan.animateHammerFrame] {
            print("checkBarrelHit frame \(jumpMan.animateHammerFrame)")
            let hammerOffset = jumpMan.frameSize.width / 4
            var hammerPos = jumpMan.position
            hammerPos.y += hammerOffset
            if jumpMan.facing == .left {
                hammerPos.x -= hammerOffset
            } else {
                hammerPos.x += hammerOffset
            }
            
            if circlesIntersect(center1: hammerPos, diameter1: jumpMan.frameSize.width / 4, center2: barrel.position, diameter2: barrel.frameSize.width / 2) {
                print("hammer frame \(jumpMan.animateHammerFrame)")
                soundFX.hammerSound()
                explode(atPosition: barrel.position)
                removeBarrel(id: barrel.id)
                pause = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                    pause = false
                }
            }
        }
    }
    
}
