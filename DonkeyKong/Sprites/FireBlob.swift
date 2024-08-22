//
//  FireBlob.swift
//  DonkeyKong
//
//  Created by Jonathan French on 20.08.24.
//

import Foundation
import SwiftUI

class FireBlob: ObservableObject {
    var id = UUID()
    let animateFrames = 9
    var animateCounter = 0
    var cFrame = 0
    var xPos = 0
    var yPos = 0
    var position = CGPoint()
    var frame = 0
    @Published
    var currentFrame:ImageResource = ImageResource(name: "FireBlob1", bundle: .main)
    var fireBlobs:[ImageResource] = [ImageResource(name: "FireBlob1", bundle: .main),ImageResource(name: "FireBlob2", bundle: .main),ImageResource(name: "FireBlob3", bundle: .main)]
    var frameSize: CGSize = CGSize(width: 32, height:  32)
    @Published
    var isShowing = false

    
    func animate() {
        animateCounter += 1
        if animateCounter == animateFrames {
            currentFrame = fireBlobs[cFrame]
            cFrame += 1
            if cFrame == 3 {
                cFrame = 0
            }
            animateCounter = 0
        }
    }
}
