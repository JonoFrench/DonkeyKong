//
//  GameManager+Barrels.swift
//  DonkeyKong
//
//  Created by Jonathan French on 21.08.24.
//

import Foundation

extension GameManager {
    
    func throwBarrel(){
        if Int.random(in: 0..<200) == 25 && !kong.isThrowing {
            if Int.random(in: 0..<10) == 5 {
                throwBarrelDown()
            } else {
                kong.isThrowing = true
                kong.currentFrame = kong.kongLeft
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    kong.currentFrame = kong.kongRight
                    barrelArray.add(thrown: false)
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
            barrelArray.add(thrown: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                kong.currentFrame = kong.kongFacing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                    kong.isThrowing = false
                }
            }
        }
    }
    
    func checkBarrelJumped(barrel:Barrel) {
        guard !gameScreen.hasPoints && jumpMan.isJumping  else { return }
        var barrelPos = barrel.position
        barrelPos.y -= barrel.frameSize.height

        if circlesIntersect(center1: jumpMan.position, diameter1: jumpMan.frameSize.width, center2: barrelPos, diameter2: barrel.frameSize.width) {
            addPoints(value: 100, position: barrel.position)
            soundFX.barrelJumpSound()
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
                explode(sprite: barrel)
                barrelArray.remove(id: barrel.id)
                gameScreen.pause = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                    gameScreen.pause = false
                }
            }
        }
    }
    
    func checkJumpManHit(barrel:Barrel) {
        guard !jumpMan.isDying && !turnOffCollisions else { return }
        if circlesIntersect(center1: jumpMan.position, diameter1: jumpMan.frameSize.width / 2, center2: barrel.position, diameter2: barrel.frameSize.width / 2) {
            barrelArray.remove(id: barrel.id)
            jumpMan.dead()
        }
    }
 
    func checkJumpManHit(fireBlob:FireBlob) {
        guard !jumpMan.isDying && !turnOffCollisions else { return }
        if circlesIntersect(center1: jumpMan.position, diameter1: jumpMan.frameSize.width / 2, center2: fireBlob.position, diameter2: fireBlob.frameSize.width / 2) {
            fireBlobArray.remove(id: fireBlob.id)
            jumpMan.dead()
        }
    }

    func checkJumpManHit(pie:Pie) {
        guard !jumpMan.isDying && !turnOffCollisions else { return }
        if circlesIntersect(center1: jumpMan.position, diameter1: jumpMan.frameSize.width / 2, center2: pie.position, diameter2: pie.frameSize.width / 2) {
            pieArray.remove(id: pie.id)
            jumpMan.dead()
        }
    }

    func checkJumpManHit(spring:Spring) {
        guard !jumpMan.isDying && !turnOffCollisions else { return }
        if circlesIntersect(center1: jumpMan.position, diameter1: jumpMan.frameSize.width / 2, center2: spring.position, diameter2: spring.frameSize.width / 2) {
            springArray.remove(id: spring.id)
            jumpMan.dead()
        }
    }
}
