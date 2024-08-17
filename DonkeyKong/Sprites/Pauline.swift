//
//  Pauline.swift
//  DonkeyKong
//
//  Created by Jonathan French on 17.08.24.
//

import Foundation
import SwiftUI

struct Pauline {
    var xPos = 0
    var yPos = 0
    var paulinePosition = CGPoint()
    var frame = 0
    var currentFrame:ImageResource = ImageResource(name: "Pauline1", bundle: .main)
    
    var standing:[ImageResource] = [ImageResource(name: "Pauline1", bundle: .main),ImageResource(name: "Pauline2", bundle: .main),ImageResource(name: "Pauline3", bundle: .main),ImageResource(name: "Pauline4", bundle: .main)]
    var frameSize: CGSize = CGSize(width: 63, height:  36)
    var isShowing = false
}
