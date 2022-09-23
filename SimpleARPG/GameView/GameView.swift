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

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                    .zIndex(1)

                VStack(spacing: 0) {

                    GeometryReader { geometry in
                        ZStack {
                            Color.black.ignoresSafeArea()

                            Image("town")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .opacity(0.75)

                            VStack {
                                if let encounter = viewStore.encounter {
                                    if viewStore.player.isDead {
                                        YouDiedView(didTapRevive: { viewStore.send(.reviveTapped) }, playerDamageLog: viewStore.player.damageLog, monsterDamageLog: encounter.monster.damageLog)
                                            .transition(.opacity)
                                    } else if encounter.monster.isDead {
                                        YouWonView(didTapExit: { viewStore.send(.exitEncounterTapped) })
                                            .transition(.opacity)
                                    } else {
                                        HStack {
                                            EncounterModifierPreview(encounter: encounter)
                                                .padding([.leading, .top], 12)
                                            Spacer()
                                        }
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

                                VStack {
                                    Button(action: {
                                        viewStore.send(.addRandomEncounter)
                                    }) {
                                        Text("Add random encounter")
                                            .font(.appCaption)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.top, 12)

                                Spacer()

                                ZStack(alignment: .bottom) {

                                    HStack(alignment: .bottom) {
                                        PlayerView(store: store, player: viewStore.player)
                                        Spacer()
                                        if let monster = viewStore.encounter?.monster {
                                            VStack {
                                                Text(monster.name)
                                                    .font(.appFootnote)
                                                    .foregroundColor(.white)
                                                ResourceBar(current: monster.currentLife, total: monster.maxLife, frontColor: .uiGreen, backColor: .uiRed, icon: "", showTotal: false, width: 80, height: 20)
                                                PlayerView(store: store, player: monster, xScale: -1)
                                            }
                                        } else {
                                            ForEach(viewStore.vendors) { vendor in
                                                VendorView(vendor: vendor, store: store.scope(state: \.vendorViewState, action: GameAction.vendorViewAction))
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding(.bottom, 6)

                            ForEach(viewStore.vendors.filter { $0.isActive }) { vendor in
                                VendorInventoryView(vendor: vendor, store: store.scope(state: \.vendorViewState, action: GameAction.vendorViewAction))
                            }
                        }
                    }

                    VStack(spacing: 0) {
                        ResourceBarStack(store: store)
                        TabRowView(tabs: [.specialAttack, .stats, .inventory, .equipment, .spells], store: store)

                        Divider().background(Color.black)

                        Group {
                            switch viewStore.selectedTab {
                            case .specialAttack:
                                SpecialAttackView(store: store.scope(state: \.specialAttack, action: GameAction.specialAttack))
                            case .messages:
                                MessageView(store: store.scope(state: \.messageState, action: GameAction.messageAction))
                            case .stats:
                                StatsView(store: store.scope(state: \.statsViewState, action: GameAction.statsViewAction))
                            case .inventory:
                                HStack {
                                    PlayerInventoryView(store: store.scope(state: \.inventoryState, action: GameAction.inventoryAction))

                                    if let encounter = viewStore.encounter {
                                        VStack(spacing: 8) {
                                            Text("\(encounter.monster.icon.asset)")
                                                .font(.appSubheadline)
                                                .foregroundColor(.white)
                                            InventoryGrid(
                                                inventory: encounter.monster.inventory,
                                                slotBackgroundColor: { _ in .uiButton },
                                                contextMenu: nil,
                                                dropDelegate: nil,
                                                inventorySlotTapped: { slot in
                                                    if encounter.monster.isDead {
                                                        viewStore.send(.attemptLoot(slot))
                                                    }
                                                },
                                                onDrag: nil
                                            )
                                            .opacity(encounter.monster.isDead ? 1 : 0.5)
                                            Spacer()
                                        }
                                    }
                                }
                                .padding(12)
                            case .equipment:
                                EquipmentView(store: store)
                            case .spells:
                                TalentTreeView(store: store.scope(state: \.talentTreeState, action: GameAction.talentTreeAction))
                                    .zIndex(-1)
                            case .settings:
                                Text("Unimplemented")
                            }
                        }
                        .frame(height: 40 * 7)
                        .background(Color.uiBackground.frame(width: screen.width))

                        Divider().background(Color.black)

                        TabRowView(tabs: [.messages, .settings], store: store)

                        Divider().background(Color.black)
                        Divider().background(Color.uiDarkBackground)
                    }
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
                            .transition(.opacity)
                    }
                    .zIndex(5)
                }

                if !viewStore.didSetup {
                    LoadingView()
                        .zIndex(10) // Need to specify zIndex here because of animations
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct LoadingView: View {

    @State var isLoading: Bool = false

    var body: some View {
        Rectangle()
            .fill(Color.white)
            .edgesIgnoringSafeArea(.all)
            .overlay {
                VStack(spacing: 4) {
                    HStack {
                        Text("🌀")
                            .font(.appSubheadline)
                            .foregroundColor(.black)
                            .rotationEffect(.degrees(isLoading ? 360 : 0))
                            .animation(Animation.spring().repeatForever(), value: isLoading)
                        Text("Loading...")
                            .font(.appSubheadline)
                            .foregroundColor(.black)
                    }
                    Text("[BETA] If you're stuck here, please reinstall the app fresh!")
                        .font(.appFootnote)
                        .foregroundColor(.black.opacity(0.6))
                }
            }
            .onAppear {
                isLoading.toggle()
            }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(store: .init(initialState: .init(), reducer: gameReducer, environment: .live))
    }
}
