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
    case hammer,umbrella,hat,diamond
}

class Collectible: ObservableObject {
    var id = UUID()
    var xPos = 0
    var yPos = 0
    var type: CollectibleType = .hammer
    var position = CGPoint()
    var currentFrame:ImageResource = ImageResource(name: "Hammer", bundle: .main)
    var frameSize: CGSize = CGSize(width: 24, height:  24)
    @Published
    var collected = false
    
    init(type: CollectibleType, xPos: Int, yPos:Int) {
        self.type = type
        self.xPos = xPos
        self.yPos = yPos
    }
        
    func collectibleImage() -> ImageResource  {
        switch type {
        case .hammer : return ImageResource(name: "Hammer", bundle: .main)
        case .umbrella: return ImageResource(name: "Umbrella", bundle: .main)
        case .hat: return ImageResource(name: "Hat", bundle: .main)
        case .diamond: return ImageResource(name: "Diamond", bundle: .main)
        }
    }
}
