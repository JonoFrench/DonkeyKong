//
//  DonkeyKongApp.swift
//  DonkeyKong
//
//  Created by Jonathan French on 11.08.24.
//

import SwiftUI

@main
struct DonkeyKongApp: App {
    @StateObject private var manager = GameManager()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(manager)
        }
    }
}
