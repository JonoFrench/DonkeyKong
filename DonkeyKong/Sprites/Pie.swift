//
//  Pie.swift
//  DonkeyKong
//
//  Created by Jonathan French on 3.09.24.
//

import Foundation
import SwiftUI

final class PieArray: ObservableObject {
    @Published var pies: [Pie] = []
    var direction:ConveyorDirection = .left {
        didSet {
            for pie in pies where pie.yPos == ConveyorPos.bottom.rawValue {
                pie.direction = direction
            }
        }
    }
    
    func movePies() {
        for pie in pies {
            pie.move()
        }
    }
}

final class Pie:SwiftUISprite, Moveable, ObservableObject {
    static var animateFrames: Int = 2
    static var speed: Int = 1
    static var moveFrames = 4
    static var fireConveyor = 12
    static var oilDrumLeft = 14
    static var oilDrumRight = 15

    var speedCounter: Int = 0
    var animateCounter: Int = 0
    var moveCounter = 0

    var direction:ConveyorDirection = .left
    
    init(xPos: Int, yPos: Int, direction:ConveyorDirection) {
        super.init(xPos: xPos, yPos: yPos, frameSize: CGSize(width: 32, height: 18))
        self.direction = direction
        currentFrame = ImageResource(name: "Pie", bundle: .main)
        setPosition()
    }

    func move() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            speedCounter += 1
            if speedCounter == Kong.speed {
                speedCounter = 0
                moveCounter += 1
                if direction == .left {
                    position.x -= resolvedInstance.assetDimention / CGFloat(Pie.moveFrames)
                } else {
                    position.x += resolvedInstance.assetDimention / CGFloat(Pie.moveFrames)
                }
                if moveCounter == Pie.moveFrames {
                    moveCounter = 0
                    if direction == .left {
                        xPos -= 1
                        if xPos == 0 {
                            let pieID:[String: UUID] = ["id": self.id]
                            NotificationCenter.default.post(name: .notificationRemovePie, object: nil, userInfo: pieID)
                        } else if xPos == Pie.oilDrumLeft  && yPos == Pie.fireConveyor {
                            let pieID:[String: UUID] = ["id": self.id]
                            NotificationCenter.default.post(name: .notificationPieToFireblob, object: nil, userInfo: pieID)
                        }
                    } else {
                        xPos += 1
                        if xPos == 28 {
                            let pieID:[String: UUID] = ["id": self.id]
                            NotificationCenter.default.post(name: .notificationRemovePie, object: nil, userInfo: pieID)
                        } else if xPos == Pie.oilDrumRight && yPos == Pie.fireConveyor {
                            let pieID:[String: UUID] = ["id": self.id]
                            NotificationCenter.default.post(name: .notificationPieToFireblob, object: nil, userInfo: pieID)

                        }
                    }
                }
            }
        }
    }
}
