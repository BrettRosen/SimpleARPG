//
//  ContentView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import ComposableArchitecture
import Foundation
import GameplayKit
import SwiftUI

#if canImport(UIKit)
let screen = UIScreen.main.bounds
#elseif canImport(AppKit)
let screen = NSScreen.main!.frame
#endif

struct GameView: View {

    let store: Store<GameState, GameAction>

    @State var tree = uniqueTree

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)

                VStack {
                    ZStack {
                        VStack {
                            if let encounter = viewStore.encounter {
                                HStack {
                                    EncounterModifierPreview(encounter: encounter)
                                        .padding([.leading, .top], 12)
                                    Spacer()
                                }

                                if encounter.combatBeginTimerCount >= 0 {
                                    VStack {
                                        Spacer()
                                        Text(encounter.combatBeginTimerCount > 0 ? "\(encounter.combatBeginTimerCount)" : "⚔️FIGHT⚔️")
                                            .font(.appSubheadline)
                                            .foregroundColor(encounter.combatBeginTimerCount > 0 ? .black : .uiRed)
                                        Spacer()
                                    }
                                }
                            }
                            Button(action: {
                                viewStore.send(.addRandomEncounter)
                            }) {
                                Text("Add random encounter")
                            }

                            Spacer()

                            HStack(alignment: .bottom) {
                                PlayerView(store: store)
                                Spacer()
                                MonsterView(store: store)
                            }
                            .padding(.horizontal, 24)
                        }

                        VStack {
                            if viewStore.player.isDead {
                                YouDiedView(didTapRevive: { viewStore.send(.reviveTapped) })
                            }
                        }
                    }

                    VStack(spacing: 0) {
                        ResourceBarStack(store: store)
                        TabRowView(store: store)

                        Divider().background(Color.black)

                        Group {
                            switch viewStore.selectedTab {
                            case .stats:
                                StatsView(store: store.scope(state: \.statsViewState, action: GameAction.statsViewAction))
                            case .inventory:
                                HStack {
                                    PlayerInventoryView(store: store.scope(state: \.inventoryState, action: GameAction.inventoryAction))

                                    if let encounter = viewStore.encounter {
                                        Divider()
                                            .frame(width: 1, height: 200)
                                            .overlay(Color.uiBorder)
                                        VStack(spacing: 8) {
                                            Text("\(encounter.monster.icon)")
                                                .font(.appSubheadline)
                                                .foregroundColor(.white)
                                            InventoryGrid(
                                                inventory: encounter.monster.inventory,
                                                slotBackgroundColor: { _ in .uiButton },
                                                contextMenu: nil,
                                                dropDelegate: nil,
                                                inventorySlotTapped: nil,
                                                onDrag: nil
                                            )
                                            .opacity(0.5)
                                            Spacer()
                                        }
                                    }
                                }
                                .padding(12)
                            case .equipment:
                                EquipmentView(store: store)
                            case .spells:
                                Diagram(tree: tree) { value in
                                    Text("\(value.value)")
                                }
                            case .settings:
                                Text("Unimplemented")
                            }
                        }
                        .frame(height: 40 * 7)
                        .background(Color.uiBackground.frame(width: screen.width).edgesIgnoringSafeArea(.bottom))
                    }
                    .frame(height: screen.height / 2.4)
                }
                .zIndex(1)

                // MARK: Item Preview
                if let previewItem = viewStore.currentPreviewingItem {
                    Group {
                        Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                viewStore.send(.closePreview, animation: .default)
                            }
                        VStack {
                            ItemPreview(item: previewItem)

                            // If the item we're previewing is equipment & player has an equipment in that slot...
                            if case let .equipment(equipment) = previewItem,
                               let playersEquipment = viewStore.player.allEquipment.first(where: { $0.base.slot == equipment.base.slot }) {

                                ItemPreview(item: .equipment(playersEquipment))
                            }
                        }
                    }
                    .zIndex(5)
                }

                if let previewingEncounter = viewStore.previewingEncounter {
                    Group {
                        Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                viewStore.send(.closePreview, animation: .default)
                            }
                            .transition(.opacity)
                        EncounterConfirm(store: store, encounter: previewingEncounter.encounter)
                            .transition(.slide)
                    }
                    .zIndex(5)
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(store: .init(initialState: .init(), reducer: gameReducer, environment: .live))
    }
}
