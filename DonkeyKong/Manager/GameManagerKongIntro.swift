//
//  GameManagerKongIntro.swift
//  DonkeyKong
//
//  Created by Jonathan French on 16.08.24.
//

import Foundation

extension GameManager {
 
    func setKongIntro() {
        gameState = .kongintro
        screenData = KongScreen().getScreenData()
        kong.xPos = 16
        kong.yPos = 25
        kong.animationCounter = 0
        kong.position = calcPositionFromScreen(xPos: kong.xPos, yPos: kong.yPos,frameSize: kong.frameSize)
        adjustKongPosition()
        setLadders()
        runKongIntro()
    }
    
    func setLadders() {
        for i in 8..<27 {
            screenData[i][15] = ScreenAsset(assetType: .ladder, assetOffset: 0.0)
            screenData[i][17] = ScreenAsset(assetType: .ladder, assetOffset: 0.0)
        }
    }
    
    func bendLine(line:Int) {
        var assetLine = Screens().screen1[line]
        assetLine.indices.forEach{ assetLine[$0].assetOffset -= 4 }
        screenData[line] = assetLine
    }
    
    func clearLadder(line:Int) {
        if screenData[line][14].assetType == .girder {
            screenData[line][15] = ScreenAsset(assetType: .girder, assetOffset: 0.0)
            screenData[line][17] = ScreenAsset(assetType: .girder, assetOffset: 0.0)
        } else {
            screenData[line][15] = ScreenAsset(assetType: .blank, assetOffset: 0.0)
            screenData[line][17] = ScreenAsset(assetType: .blank, assetOffset: 0.0)
        }
    }
    
    func animateKongIntro() {
        kong.animationCounter += 1
        if kong.animationCounter == 14 {
            
            kongIntroCounter -= 1
            if kongIntroCounter > 10 {
                clearLadder(line: kongIntroCounter)
                nextStepUp()
            } else {
                kong.state = .jumpingup
                kongIntroCounter = 0
                
            }
            kong.animationCounter = 0
        }
    }
        
    func animateKongJumpUp() {
        kong.animationCounter += 1

        if kong.animationCounter == 4 {
            kong.position = calcPositionFromScreen(xPos: kong.xPos, yPos: kong.jumpingPoints[kongIntroCounter],frameSize: kong.frameSize)
            adjustKongPosition()
            kongIntroCounter += 1
            if kongIntroCounter > kong.jumpingPoints.count - 1 {
                kong.yPos = 7
                generateBouncingPoints()
                pauline.position = calcPositionFromScreen(xPos: 14, yPos: 3,frameSize: pauline.frameSize)
                pauline.isShowing = true
                kong.position = calcPositionFromScreen(xPos: kong.xPos, yPos: kong.yPos,frameSize: kong.frameSize)
                adjustKongPosition()
                kong.currentFrame = kong.kongFacing
                kong.state = .sitting
                bendLine(line: 7)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    kong.state = .bouncing
                }
            }
            kong.animationCounter = 0
        }
    }
    
    func animateKongHop(){
        kong.animationCounter += 1
        if kong.animationCounter == 4 {
            kong.position = kong.bouncingPoints[kong.bouncePos][kong.bounceYPos]
            adjustKongPosition()
            kong.bounceYPos += 1
            if kong.bounceYPos == kong.bouncingPoints[kong.bouncePos].count {
                bendLine(line: 11 + (kong.bouncePos * 4))
                kong.bouncePos += 1
                kong.bounceYPos = 0
            }
            if kong.bouncePos == 5 {
                kong.state = .sitting
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [self] in
                    showHowHigh()
                }
            }
            kong.animationCounter = 0
        }
    }
    
    func showHowHigh(){
        gameState = .howhigh
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [self] in
            startPlaying()
        }
    }
    
    func runKongIntro() {
        soundFX.introLongSound()
        kong.state = .intro
        kongIntroCounter = 27
        clearLadder(line: kongIntroCounter)
        }
        
    func nextStepUp() {
        kong.kongStep = !kong.kongStep
        if kong.kongStep {
            kong.currentFrame = kong.kongClimbLeft
        } else {
            kong.currentFrame = kong.kongClimbRight
        }
        kong.yPos -= 1
        kong.position = calcPositionFromScreen(xPos: kong.xPos, yPos: kong.yPos,frameSize: kong.frameSize)
        adjustKongPosition()
    }
    
    func adjustKongPosition() {
        kong.position.y += 9
        kong.position.x += assetDimention / 2
    }

    func generateBouncingPoints() {
        var c = 0
        for i in stride(from: 16, through: 8, by: -2) {
            var pointA = calcPositionFromScreen(xPos: i, yPos: kong.yPos,frameSize: kong.frameSize)
            pointA.y -= 4.0
            var pointB = calcPositionFromScreen(xPos: i - 2, yPos: kong.yPos,frameSize: kong.frameSize)
            pointB.y -= 4.0
            let points = generateParabolicPoints(from: pointA, to: pointB, angleInDegrees: -50)
            kong.bouncingPoints.append(points)
            c += 1
        }
    }
    
    func generateParabolicPoints(from pointA: CGPoint, to pointB: CGPoint, steps: Int = 9, angleInDegrees: CGFloat = 10) -> [CGPoint] {
        var points: [CGPoint] = []
        
        // Horizontal distance between pointA and pointB
        let dx = pointB.x - pointA.x
        
        // Height of the parabola (peak) based on 10 degrees
        let peakHeight = (dx / 2) * tan(angleInDegrees * .pi / 180)
        
        // Midpoint (vertex of the parabola)
        let midPointX = (pointA.x + pointB.x) / 2
        let vertex = CGPoint(x: midPointX, y: pointA.y - peakHeight)
        
        // Parabola equation: y = a(x - h)^2 + k
        // We need to solve for 'a' given points A and vertex
        let a = (pointA.y - vertex.y) / pow(pointA.x - vertex.x, 2)
        
        // Generate points along the parabola
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let x = pointA.x + t * (pointB.x - pointA.x)
            let y = a * pow(x - vertex.x, 2) + vertex.y
            points.append(CGPoint(x: x, y: y))
        }
        
        return points
    }
}
