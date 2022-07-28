//
//  SimpleARPGApp.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import SwiftUI

@main
struct SimpleARPGApp: App {
    var body: some Scene {
        WindowGroup {
            GameView(store: .init(initialState: .init(), reducer: gameReducer, environment: .live))
        }
    }
}
