//
//  LoftLadder.swift
//  DonkeyKong
//
//  Created by Jonathan French on 3.09.24.
//

import Foundation
import SwiftUI

enum LadderState {
    case opening, closing
}

final class Ladders: ObservableObject {
    @Published var leftLadder = LoftLadder(xPos: 4, yPos: 12)
    @Published var rightLadder = LoftLadder(xPos: 26, yPos: 12)
}

final class LoftLadder:SwiftUISprite, Animatable, ObservableObject {
    static var animateFrames: Int = 20
    static var moveFrames: Int = 4

    var animateCounter: Int = 0
    var moveCounter = 0
    @Published
    var offset = 0.0
    
    var state:LadderState = .opening
    
    init(xPos: Int, yPos: Int) {
        var frame = CGSize()
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            frame.width = resolvedInstance.assetDimention + 4
            frame.height = resolvedInstance.assetDimention
        }
        super.init(xPos: xPos, yPos: yPos, frameSize: frame)
        currentFrame = ImageResource(name: "LadderWhite", bundle: .main)
        setPosition()
    }

    func animate() {
        animateCounter += 1
        if animateCounter == LoftLadder.animateFrames {
            animateCounter = 0
            if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
                if state == .opening {
                    offset -= resolvedInstance.assetDimention / CGFloat(LoftLadder.moveFrames)
                } else {
                    offset += resolvedInstance.assetDimention / CGFloat(LoftLadder.moveFrames)
                }
                moveCounter += 1
                if moveCounter == LoftLadder.moveFrames {
                    moveCounter = 0
                    state = state == .opening ? .closing : .opening
                }
            }
        }
    }
}
