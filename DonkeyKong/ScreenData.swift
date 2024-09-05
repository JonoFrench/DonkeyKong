//
//  ScreenData.swift
//  DonkeyKong
//
//  Created by Jonathan French on 28.08.24.
//

import Foundation
import SwiftUI

final class ScreenData:ObservableObject {
    @Published
    var screenData:[[ScreenAsset]] = [[]]
    let screenDimentionX:Int = 30
    let screenDimentionY:Int = 28
    var assetDimention = 0.0
    var assetOffset = 0.0
    var verticalOffset = 0.0
    var gameSize = CGSize()
    var screenSize = CGSize()
    @Published
    var level:Int = 1 {
        didSet {
            if level > 4 {
                level = 1
            }
        }
    }
    var levelEnd = false
    var hasFlames = false
    var hasExplosion = false
    var hasPoints = false
    var hasElevators = false
    var hasSprings = false
    var hasConveyor = false
    var hasLoftLadders = false
    var girderPlugs = 0
    var pause = false

    /// Set Ladders for intro
    func setLadders() {
        for i in 8..<27 {
            screenData[i][15] = ScreenAsset(assetType: .ladder, assetOffset: 0.0)
            screenData[i][17] = ScreenAsset(assetType: .ladder, assetOffset: 0.0)
        }
    }
    /// Clear ladder as kong moves up in intro
    func clearLadder(line:Int) {
        if screenData[line][14].assetType == .girder {
            screenData[line][15] = ScreenAsset(assetType: .girder, assetOffset: 0.0)
            screenData[line][17] = ScreenAsset(assetType: .girder, assetOffset: 0.0)
        } else {
            screenData[line][15] = ScreenAsset(assetType: .blank, assetOffset: 0.0)
            screenData[line][17] = ScreenAsset(assetType: .blank, assetOffset: 0.0)
        }
    }
    /// Bent line as kong leaves intro
    func bendLine(line:Int,assets:[ScreenAsset]) {
        var assetLine = assets
        assetLine.indices.forEach{ assetLine[$0].assetOffset -= 4 }
        screenData[line] = assetLine
        self.objectWillChange.send()
    }
    /// Level 4 finish clear screen and set girders to bottom
    func clearFinalLevel() {
        for y in 7...26 {
            for x in 7...21 {
                screenData[y][x].assetType = .blank
            }
        }
        for y in 23...26 {
            for x in 8...20 {
                screenData[y][x].assetType = .girder
            }
        }
    }
}

class ServiceLocator {
    static let shared = ServiceLocator()
    private init() {}
    
    private var services: [String: AnyObject] = [:]
    
    func register<T>(service: T) {
        let key = "\(T.self)"
        services[key] = service as AnyObject
    }
    
    func resolve<T>() -> T? {
        let key = "\(T.self)"
        return services[key] as? T
    }
}
