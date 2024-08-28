//
//  ScreenData.swift
//  DonkeyKong
//
//  Created by Jonathan French on 28.08.24.
//

import Foundation
import SwiftUI

class ScreenData:ObservableObject {
    @Published
    var screenData:[[ScreenAsset]] = [[]]
    let screenDimentionX:Int = 30
    let screenDimentionY:Int = 28
    var assetDimention = 0.0
    var assetOffset = 0.0
    var verticalOffset = 0.0
    var gameSize = CGSize()
    var screenSize = CGSize()
    
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
    func bendLine(line:Int,assets:[ScreenAsset]) {
        var assetLine = assets
        assetLine.indices.forEach{ assetLine[$0].assetOffset -= 4 }
        screenData[line] = assetLine
        self.objectWillChange.send()
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
