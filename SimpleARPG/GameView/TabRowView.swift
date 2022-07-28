//
//  TabRowView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/27/22.
//

import ComposableArchitecture
import SwiftUI

struct TabRowView: View {
    let store: Store<GameState, GameAction>

    @Namespace private var tabAnimation

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                TabView(tab: .stats, selectedTab: viewStore.selectedTab, namespace: tabAnimation) {
                    viewStore.send(.updateTab(.stats))
                }
                TabView(tab: .inventory, selectedTab: viewStore.selectedTab, namespace: tabAnimation) {
                    viewStore.send(.updateTab(.inventory))
                }
                TabView(tab: .equipment, selectedTab: viewStore.selectedTab, namespace: tabAnimation, statusText: viewStore.player.weapon == nil ? "❗️Unarmed" : "") {
                    viewStore.send(.updateTab(.equipment))
                }
                TabView(tab: .spells, selectedTab: viewStore.selectedTab, namespace: tabAnimation) {
                    viewStore.send(.updateTab(.spells))
                }
                TabView(tab: .settings, selectedTab: viewStore.selectedTab, namespace: tabAnimation) {
                    viewStore.send(.updateTab(.settings))
                }
            }
            .padding(8)
            .frame(width: screen.width)
            .background(Color.uiBackground)
        }
    }
}
