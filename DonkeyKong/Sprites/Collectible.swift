//
//  Collectibles.swift
//  DonkeyKong
//
//  Created by Jonathan French on 18.08.24.
//

import Foundation

import Foundation
import SwiftUI

enum CollectibleType {
    case hammer,umbrella,hat,phone,heart,heartbreak
}

class Collectible:SwiftUISprite, ObservableObject {
    var type: CollectibleType = .hammer
    @Published
    var collected = false
    
    init(type: CollectibleType, xPos: Int, yPos:Int) {
        super.init(xPos: xPos, yPos: yPos, frameSize: CGSize(width: 24, height:  18))
        self.type = type
        currentFrame = collectibleImage()
    }
        
    func collectibleImage() -> ImageResource  {
        switch type {
        case .hammer : return ImageResource(name: "Hammer", bundle: .main)
        case .umbrella: return ImageResource(name: "Umbrella", bundle: .main)
        case .hat: return ImageResource(name: "Hat", bundle: .main)
        case .phone: return ImageResource(name: "Diamond", bundle: .main)
        case .heart: return ImageResource(name: "Heart", bundle: .main)
        case .heartbreak: return ImageResource(name: "HeartBreak", bundle: .main)
        }
    }
    func collectibleScore() -> Int {
        switch type {
        case .hammer : return 0
        case .umbrella: return 200
        case .hat: return 300
        case .phone: return 300
        case .heart: return 0
        case .heartbreak: return 0
        }

    }
    
}
