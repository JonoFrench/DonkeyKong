//
//  DKFunctions.swift
//  DonkeyKong
//
//  Created by Jonathan French on 18.08.24.
//

import Foundation
import SwiftUI

class DKFunctions {
    var assetDimention:Double = 0.0
    var gameSize = CGSize()
    var screenSize = CGSize()

    init(assetDimention: Double) {
        self.assetDimention = assetDimention
    }
    
    func calcPositionForXY(xPos:Int, yPos:Int, frameSize:CGSize) -> CGPoint  {
        return CGPoint(x: assetDimention * Double(xPos) + (frameSize.width / 2) + (assetDimention / 2), y: assetDimention * Double(yPos) - (frameSize.height / 2) - 80 - (assetDimention / 2))
    }

    
}
