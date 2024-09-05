//
//  Elevator.swift
//  DonkeyKong
//
//  Created by Jonathan French on 31.08.24.
//

import Foundation

enum ElevatorDirection {
    case up,down
}
enum ElevatorPart {
    case lift,control
}

final class ElevatorArray: ObservableObject {
    @Published 
    var elevators: [Elevator] = []
    
    func move() {
        for elevator in elevators {
            elevator.move()
        }
    }
    func add(direction:ElevatorDirection,part:ElevatorPart, xPos: Int, yPos:Int) {
        elevators.append(Elevator(direction: direction,part: part, xPos: xPos, yPos: yPos))
    }
}

final class Elevator:SwiftUISprite,Moveable, ObservableObject {
    static var speed: Int = AppConstant.elevatorSpeed
    
    var speedCounter: Int = 0
    var direction: ElevatorDirection = .up
    let moveFrames = 6
    var moveCounter = 0
    var part: ElevatorPart = .lift

    init(direction:ElevatorDirection,part:ElevatorPart, xPos: Int, yPos:Int) {
        var elevatorSize = CGSize()
        self.direction = direction
        self.part = part
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            elevatorSize.width = resolvedInstance.assetDimention * 2
            elevatorSize.height = resolvedInstance.assetDimention
        }
        super.init(xPos: xPos, yPos: yPos, frameSize: elevatorSize)
        setPosition()
        speedCounter = 0
    }
    
    override func setPosition() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            position = calcPositionFromScreen()
            position.x += resolvedInstance.assetDimention / 2
        }
    }
        
    func move() {
        guard part == .lift else { return }
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            speedCounter += 1
            if speedCounter == Elevator.speed {
                speedCounter = 0
                if direction == .up {
                    position.y -= resolvedInstance.assetDimention / CGFloat(moveFrames)

                } else {
                    position.y += resolvedInstance.assetDimention / CGFloat(moveFrames)

                }
                moveCounter += 1
                if moveCounter == moveFrames {
                    moveCounter = 0
                    if direction == .up {
                        yPos -= 1
                        if yPos == 9 {
                            yPos = 27
                            setPosition()
                        }
                    } else {
                        yPos += 1
                        if yPos == 27 {
                            yPos = 9
                            setPosition()
                        }
                    }
                }
            }
        }
    }
}
