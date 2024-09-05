//
//  Spring.swift
//  DonkeyKong
//
//  Created by Jonathan French on 1.09.24.
//

import Foundation
import SwiftUI

final class SpringArray: ObservableObject {
    @Published var springs: [Spring] = []
    static let springX = 2
    static let springY = 7
    var springAdded = false

    func move(){
        for spring in springs {
            spring.animate()
            spring.move()
        }
    }
    func remove(id:UUID) {
        if let index = springs.firstIndex(where: {$0.id == id}) {
            springs.remove(at: index)
        }
    }
    
    func add() {
        let spring = Spring(xPos: SpringArray.springX + Int.random(in: 0..<3), yPos: SpringArray.springY, frameSize: CGSize(width: 24, height:  24))
        springs.append(spring)
        springAdded = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            springAdded = false
        }
    }

}
enum SpringState {
    case bouncing, falling
}

final class Spring:SwiftUISprite,Animatable, Moveable, ObservableObject {
    static var animateFrames: Int = 2
    static var speed: Int = 1
    var speedCounter: Int = 0
    var animateCounter: Int = 0
    var bouncingPoints = [[CGPoint]]()
    var bouncePos = 0
    var bounceYPos = 0
    var state:SpringState = .bouncing
    let moveFrames = 3
    var moveCounter = 0

    let springOpen:ImageResource = ImageResource(name: "SpringOpen", bundle: .main)
    let springClosed:ImageResource = ImageResource(name: "SpringClosed", bundle: .main)

    func animate() {
        
        if state == .bouncing {
            animateBounce()
        }
    }
    
    func move() {
        if state == .falling {
            if let resolvedInstance: ScreenData = ServiceLocator.shared.resolve() {
                speedCounter += 1
                if speedCounter == Spring.speed {
                    speedCounter = 0
                    position.y += resolvedInstance.assetDimention / CGFloat(moveFrames)
                    moveCounter += 1
                    if moveCounter == moveFrames {
                        moveCounter = 0
                        yPos += 1
                        if yPos == 28 {
                            let springID:[String: UUID] = ["id": self.id]
                            NotificationCenter.default.post(name: .notificationRemoveSpring, object: nil, userInfo: springID)

                        }
                    }

                }
            }
        }
    }
    
    func animateBounce(){
            animateCounter += 1
            if animateCounter == 4 {
                position = bouncingPoints[bouncePos][bounceYPos]
                bounceYPos += 1
                if bounceYPos == bouncingPoints[bouncePos].count {
                    bouncePos += 1
                    bounceYPos = 0
                }
                currentFrame = bounceYPos < 3 ? springClosed : springOpen
                if bouncePos == bouncingPoints.count {
                    currentFrame = springOpen
                    state = .falling
                }
                animateCounter = 0
            }
    }
    
    override init(xPos: Int, yPos: Int, frameSize: CGSize) {
        super .init(xPos: xPos, yPos: yPos, frameSize: frameSize)
        currentFrame = springOpen
        generateBouncingPoints()
        print("Spring bounce num \(bouncingPoints.count)")
    }
    
    func generateBouncingPoints() {
        var c = 0
        for i in stride(from: xPos, through: 18+xPos, by: 3) {
            let pointA = calcPositionFromScreen(xPos: i, yPos: yPos,frameSize: frameSize)
            let pointB = calcPositionFromScreen(xPos: i + 3, yPos: yPos,frameSize: frameSize)
            bouncingPoints.append(generateParabolicPoints(from: pointA, to: pointB, angleInDegrees: 70))
            c += 1
        }
    }
    
}
