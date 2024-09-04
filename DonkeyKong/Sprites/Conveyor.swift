//
//  Conveyor.swift
//  DonkeyKong
//
//  Created by Jonathan French on 2.09.24.
//

import Foundation
import SwiftUI

enum ConveyorDirection {
    case left,right
}

enum ConveyorSide {
    case leftSide,rightSide
}

enum ConveyorPos:Int {
    case top = 12,bottom = 22
}


final class ConveyorArray: ObservableObject {
    @Published var conveyors: [Conveyor] = []
    
    func moveConveyors() {
        for conveyor in conveyors {
            conveyor.animate()
        }
    }
}

final class Conveyor:SwiftUISprite, Animatable, ObservableObject {
    static var animateFrames:Int = 12
    var animateCounter: Int = 0
    var direction:ConveyorDirection = .left
    let moveFrames = 4
    var moveCounter = 0
    
    var rotating:[ImageResource] = [ImageResource(name: "Conveyor1", bundle: .main),ImageResource(name: "Conveyor2", bundle: .main),ImageResource(name: "Conveyor3", bundle: .main),ImageResource(name: "Conveyor4", bundle: .main)]
        
    init(xPos: Int, yPos: Int, direction:ConveyorDirection) {
        var frame = CGSize()
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            frame.width = resolvedInstance.assetDimention
            frame.height = resolvedInstance.assetDimention + 2
        }
        super.init(xPos: xPos, yPos: yPos, frameSize: frame)
        self.direction = direction
        currentFrame = ImageResource(name: "Conveyor1", bundle: .main)
        setPosition()
    }
    
    func animate() {
        animateCounter += 1
        if animateCounter == Conveyor.animateFrames {
            animateCounter = 0
            moveCounter += 1
            if direction == .left {
                currentFrame = rotating[moveCounter-1]
            } else {
                currentFrame = rotating.reversed()[moveCounter-1]
            }
            if moveCounter == moveFrames {
                moveCounter = 0
            }
        }
    }
}
