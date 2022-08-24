//
//  TabRowView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/27/22.
//

import ComposableArchitecture
import SwiftUI

struct TabRowView: View {
    let tabs: [Tab]
    let store: Store<GameState, GameAction>

    @Namespace private var tabAnimation

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                ForEach(tabs) { tab in
                    TabView(tab: tab, selectedTab: viewStore.selectedTab, namespace: tabAnimation, statusText: tab.statusText?(viewStore) ?? "") {
                        viewStore.send(.updateTab(tab))
                    }
                }
            }
            .padding(8)
            .frame(width: screen.width)
            .background(Color.uiBackground)
        }
    }
}
