//
//  StatsView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/13/22.
//

import ComposableArchitecture
import SwiftUI

extension GameState {
    var statsViewState: StatsViewState {
        get {
            StatsViewState(local: statsViewLocalState, player: player)
        } set {
            statsViewLocalState = newValue.local
            player = newValue.player
        }
    }
}

struct StatsViewLocalState: Equatable {
    enum Tab: Equatable {
        case offensive, defensive, misc
    }
    var selectedTab: Tab = .defensive
}

struct StatsViewState: Equatable {
    var local: StatsViewLocalState = .init()
    var player: Player = .init()
}

enum StatsViewAction: Equatable {
    case setSelectedTab(StatsViewLocalState.Tab)
}

struct StatsViewEnvironment: Equatable {

}

let statsViewReducer: Reducer<StatsViewState, StatsViewAction, StatsViewEnvironment> = .init { state, action, env in
    switch action {
    case let .setSelectedTab(tab):
        state.local.selectedTab = tab
    }
    return .none
}

struct StatsViewRow: View {
    let statName: String
    let statValue: String

    var body: some View {
        HStack {
            Text(statName)
            Spacer()
            Text(statValue)
        }
        .font(.appFootnote)
        .foregroundColor(.white)
    }
}

struct StatsView: View {
    let store: Store<StatsViewState, StatsViewAction>

    @Namespace var tabAnimation

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 8) {
                HStack {
                    Text("🧙🏼 Level \(viewStore.player.level)")
                        .font(.appCallout)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.bottom, 6)

                HStack(spacing: 16) {
                    VStack {
                        Text("DEFENSIVE")
                            .foregroundColor(viewStore.local.selectedTab == .defensive ? .white : .white.opacity(0.4))
                        if viewStore.local.selectedTab == .defensive {
                            Rectangle()
                                .frame(width: 10 * CGFloat("Defensive".count), height: 2)
                                .foregroundColor(.uiRed)
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 3)
                                .matchedGeometryEffect(id: "Tab", in: tabAnimation)
                        }
                    }
                    .onTapGesture {
                        viewStore.send(.setSelectedTab(.defensive), animation: .default)
                    }
                    VStack {
                        Text("OFFENSIVE")
                            .foregroundColor(viewStore.local.selectedTab == .offensive ? .white : .white.opacity(0.4))
                        if viewStore.local.selectedTab == .offensive {
                            Rectangle()
                                .frame(width: 10 * CGFloat("Offensive".count), height: 2)
                                .foregroundColor(.uiRed)
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 3)
                                .matchedGeometryEffect(id: "Tab", in: tabAnimation)
                        }
                    }
                    .onTapGesture {
                        viewStore.send(.setSelectedTab(.offensive), animation: .default)
                    }
                    VStack {
                        Text("MISC")
                            .foregroundColor(viewStore.local.selectedTab == .misc ? .white : .white.opacity(0.4))
                        if viewStore.local.selectedTab == .misc {
                            Rectangle()
                                .frame(width: 10 * CGFloat("Misc".count), height: 2)
                                .foregroundColor(.uiRed)
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 3)
                                .matchedGeometryEffect(id: "Tab", in: tabAnimation)
                        }
                    }
                    .onTapGesture {
                        viewStore.send(.setSelectedTab(.misc), animation: .default)
                    }
                }
                .foregroundColor(.white)
                .font(.appFootnote)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 5) {
                        switch viewStore.local.selectedTab {
                        case .defensive:
                            StatsViewRow(statName: "❤️ Life", statValue: "\(viewStore.player.maxLife)")
                            StatsViewRow(statName: "🛡 Armour", statValue: "\(viewStore.player.stats[.armour]!)")
                            StatsViewRow(
                                statName: "🛡 Physical Damage Reduction",
                                statValue: "\(physicalDamageReduction(viewStore: viewStore))%")
                        case .offensive:
                            StatsViewRow(statName: "💪🏽 Strength", statValue: "\(viewStore.player.stats[.strength]!)")
                            StatsViewRow(statName: "🏃🏽 Dexterity", statValue: "\(viewStore.player.stats[.dexterity]!)")
                            StatsViewRow(statName: "🧠 Intelligence", statValue: "\(viewStore.player.stats[.intelligence]!)")
                        case .misc:
                            StatsViewRow(statName: "🪙 Item Quantity", statValue: "\(viewStore.player.stats[.incItemQuantity]! * 100)")
                            StatsViewRow(statName: "🪙 Item Rarity", statValue: "\(viewStore.player.stats[.incItemRarity]! * 100)")
                        }

                    }
                    .offset(y: 12)
                }
                .padding(.horizontal, 12)
                .background(RoundedRectangle(cornerRadius: 4).stroke(Color.uiBorder, lineWidth: 3))
            }
            .padding(12)
        }
    }

    func physicalDamageReduction(viewStore: ViewStore<StatsViewState, StatsViewAction>) -> String {
        let percentage = viewStore.player.stats[.armour]! / (viewStore.player.stats[.armour]! + 5 * Monster.baseDamage(level: viewStore.player.level))
        return String(format: "%.2f", percentage * 100)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView(store: .init(initialState: .init(), reducer: statsViewReducer, environment: .init()))
            .background(Color.uiBackground)
    }
}
