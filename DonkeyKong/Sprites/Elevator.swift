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
    static var speed: Int = GameConstants.elevatorSpeed
    
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
            elevatorSize.width = resolvedInstance.assetDimension * 2
            elevatorSize.height = resolvedInstance.assetDimension
        }
        super.init(xPos: xPos, yPos: yPos, frameSize: elevatorSize)
        setPosition()
        speedCounter = 0
    }
    
    override func setPosition() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            position = calcPositionFromScreen()
            position.x += resolvedInstance.assetDimension / 2
        }
    }
        
    func move() {
//        guard part == .lift else { return }
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            speedCounter += 1
            if speedCounter == Elevator.speed {
                speedCounter = 0
//                if direction == .up {
//                    position.y -= resolvedInstance.assetDimention / CGFloat(moveFrames)
//
//                } else {
//                    position.y += resolvedInstance.assetDimention / CGFloat(moveFrames)
//
//                }
                moveCounter += 1
                if moveCounter == moveFrames {
                    moveCounter = 0
                    moveup()
//                    if direction == .up {
//                        yPos -= 1
//                        if yPos == 9 {
//                            yPos = 27
//                            setPosition()
//                        }
//                    } else {
//                        yPos += 1
//                        if yPos == 27 {
//                            yPos = 9
//                            setPosition()
//                        }
//                    }
                }
            }
        }
    }
    
    func moveup(){
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            let leftPart = resolvedInstance.screenData[8][4].assetType
            let rightPart = resolvedInstance.screenData[8][5].assetType
            
            for i in 27...9 {
                resolvedInstance.screenData[i-1][4].assetType = resolvedInstance.screenData[i][4].assetType
                resolvedInstance.screenData[i-1][5].assetType = resolvedInstance.screenData[i][5].assetType
            }
            resolvedInstance.screenData[27][4].assetType = leftPart
            resolvedInstance.screenData[27][5].assetType = rightPart
        }
    }
}

final class Lift {
    static var speed: Int = GameConstants.elevatorSpeed
    
    var speedCounter: Int = 0
    var direction: ElevatorDirection = .up
    let moveFrames = 8
    var moveCounter = 0
    func move() {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve(), let jumpManInstance: JumpMan = ServiceLocator.shared.resolve() {
            let moveDistance = resolvedInstance.assetDimension / 8
            speedCounter += 1
            if speedCounter == Elevator.speed {
                speedCounter = 0
                moveCounter += 1
                if moveCounter == moveFrames {
                   moveCounter = 0
                    moveup()
                    movedown()
                    if jumpManInstance.onLiftUp {
                        jumpManInstance.yPos -= 1
                        jumpManInstance.position.y -= moveDistance
                        if jumpManInstance.yPos <= 9 {
                            jumpManInstance.dead()
                            return
                        }
                    }
                    if jumpManInstance.onLiftDown {
                        jumpManInstance.yPos += 1
                        jumpManInstance.position.y += moveDistance
                        if jumpManInstance.yPos > 26 {
                            jumpManInstance.dead()
                            return
                        }
                    }
                } else {
                    if jumpManInstance.onLiftUp {
                        jumpManInstance.position.y -= moveDistance
                    }
                    if jumpManInstance.onLiftDown {
                        jumpManInstance.position.y += moveDistance
                    }

                    offsetup(offset: Double(moveCounter))
                    offsetdown(offset: 8.0 - Double(moveCounter))
                }
            }
        }
    }
    
    func moveup(){
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            let leftPart = resolvedInstance.screenData[8][4].assetType
            let rightPart = resolvedInstance.screenData[8][5].assetType
            
            for i in 9...26 {
                resolvedInstance.screenData[i-1][4].assetType = resolvedInstance.screenData[i][4].assetType
                resolvedInstance.screenData[i-1][5].assetType = resolvedInstance.screenData[i][5].assetType
            }
            resolvedInstance.screenData[26][4].assetType = leftPart
            resolvedInstance.screenData[26][5].assetType = rightPart
        }
        offsetup(offset: 0.0)
    }
    
    func offsetup(offset:Double) {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            for i in 8...26 {
                resolvedInstance.screenData[i][4].assetOffset = offset
                resolvedInstance.screenData[i][5].assetOffset = offset
            }
        }
    }

    func offsetdown(offset:Double) {
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            for i in 8...26 {
                resolvedInstance.screenData[i][12].assetOffset = offset
                resolvedInstance.screenData[i][13].assetOffset = offset
            }
        }
    }

    func movedown(){
        if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
            let leftPart = resolvedInstance.screenData[26][12].assetType
            let rightPart = resolvedInstance.screenData[26][13].assetType
            
            for i in stride(from: 25, through: 8, by: -1) {
                resolvedInstance.screenData[i+1][12].assetType = resolvedInstance.screenData[i][12].assetType
                resolvedInstance.screenData[i+1][13].assetType = resolvedInstance.screenData[i][13].assetType
            }
            resolvedInstance.screenData[8][12].assetType = leftPart
            resolvedInstance.screenData[8][13].assetType = rightPart
        }
        offsetdown(offset: 8.0)

    }
}
