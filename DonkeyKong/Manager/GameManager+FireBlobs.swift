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
        let fireBlob = FireBlob(xPos: 4, yPos: 25, frameSize: CGSize(width: 18, height:  18))
        fireBlobArray.fireblob.append(fireBlob)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [fireBlob] in
            fireBlob.state = .hopping
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
}
