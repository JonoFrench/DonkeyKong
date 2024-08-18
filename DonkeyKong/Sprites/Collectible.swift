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
    case hammer,umbrella
}

class Collectible: ObservableObject {
    var id = UUID()
    var xPos = 0
    var yPos = 0
    var type: CollectibleType = .hammer
    var collectiblePosition = CGPoint()
    var currentFrame:ImageResource = ImageResource(name: "Hammer", bundle: .main)
    var frameSize: CGSize = CGSize(width: 24, height:  24)
    @Published
    var collected = false
    
    init(type: CollectibleType, xPos: Int, yPos:Int,position: CGPoint) {
        self.type = type
        self.xPos = xPos
        self.yPos = yPos
        self.collectiblePosition = position
    }
    
    
    func collectibleImage() -> ImageResource  {
        switch type {
        case .hammer : return ImageResource(name: "Hammer", bundle: .main)
        case .umbrella: return ImageResource(name: "Umbrella", bundle: .main)
        }
    }
}
