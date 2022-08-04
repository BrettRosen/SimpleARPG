//
//  ResourceBarStack.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/27/22.
//

import ComposableArchitecture
import SwiftUI

struct ResourceBarStack: View {
    let store: Store<GameState, GameAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ResourceBar(current: viewStore.player.currentLife, total: viewStore.player.maxLife, frontColor: .uiGreen, backColor: .uiRed, icon: "heart.fill", width: screen.width, height: 20)
            Divider().background(Color.black)
            ResourceBar(current: 100, total: 100, frontColor: .blue, icon: "drop.fill", width: screen.width, height: 15)
            Divider().background(Color.black)
            ResourceBar(current: 100, total: 100, frontColor: .uiPurple, icon: "sparkle", width: screen.width, height: 15)
            Divider().background(Color.black)
            ResourceBar(
                current: viewStore.player.currentLevelExperience,
                total: viewStore.player.expForNextLevel,
                frontColor: .blue,
                icon: "",
                width: screen.width,
                height: 10
            )
            Divider().background(Color.black)
        }
    }
}
