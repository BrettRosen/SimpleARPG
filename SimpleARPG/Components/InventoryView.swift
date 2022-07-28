//
//  InventoryView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import ComposableArchitecture
import Foundation
import SwiftUI

extension GameState {
    // MARK: Inventory State
    var inventoryState: InventoryState {
        get {
            InventoryState(local: inventoryLocalState, player: player, previewingEncounter: previewingEncounter, currentPreviewingItem: currentPreviewingItem)
        } set {
            inventoryLocalState = newValue.local
            player = newValue.player
            previewingEncounter = newValue.previewingEncounter
            currentPreviewingItem = newValue.currentPreviewingItem
        }
    }
}

struct InventoryLocalState: Equatable {
    var currentDraggingSlot: InventorySlot?
}

struct PreviewingEncounter: Equatable {
    var encounter: Encounter
    var slot: InventorySlot
}

struct InventoryState: Equatable {
    var local: InventoryLocalState = .init()
    var player: Player = .init()
    var previewingEncounter: PreviewingEncounter?
    var currentPreviewingItem: Item?
}

enum InventoryAction: Equatable {
    case inventorySlotTapped(InventorySlot)
    case destroyItem(in: InventorySlot)
    case setCurrentDraggingSlot(InventorySlot)
    case handleInventorySwap(fromIndex: Int, toIndex: Int, fromSlot: InventorySlot)
    case presentItemPreview(Item)

    case clearAnimation
    case clearActionLock
}

struct InventoryEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>

    static let live: Self = .init(mainQueue: .main)
}

let inventoryReducer: Reducer<InventoryState, InventoryAction, InventoryEnvironment> = .init { state, action, env in
    enum ActionLockedCancelId {}

    switch action {
    case let .setCurrentDraggingSlot(slot):
        state.local.currentDraggingSlot = slot
    case let .handleInventorySwap(fromIndex, toIndex, fromSlot):
        state.player.inventory[fromIndex] = state.player.inventory[toIndex]
        state.player.inventory[toIndex] = fromSlot
    case let .destroyItem(slot):
        guard let item = slot.item, let index = state.player.inventory.firstIndex(where: { $0 == slot }) else { return .none}
        state.player.inventory[index].item = nil
    case let .inventorySlotTapped(slot):
        guard let item = slot.item,
              let index = state.player.inventory.firstIndex(where: { $0 == slot }),
              !state.player.combatLockDetails.actionLocked
        else { return .none }

        var effects: [Effect<InventoryAction, Never>] = []

        switch item {
        case let .encounter(encounter):
            if state.previewingEncounter == nil {
                state.previewingEncounter = .init(encounter: encounter, slot: slot)
            } else {

            }
        case let .food(food):
            heal(player: &state.player, food: food, slot: slot)

            effects.append(
                Effect(value: .clearAnimation)
                    .delay(for: .init(floatLiteral: tickUnit * 3), scheduler: env.mainQueue)
                    .eraseToEffect()
                    .cancellable(id: state.player.combatLockDetails.animationEffectCancelId)
            )
        case let .equipment(equipment):
            guard state.player.canEquip(equipment) else { return .none }

            // If we already have an item of that type equipped...
            if let existingEquipment = state.player.allEquipment.first(where: { $0.base.slot == equipment.base.slot }) {

            } else {
                state.player.allEquipment.append(equipment)
                state.player.inventory[index].item = nil

                for stat in equipment.stats {
                    state.player.stats[stat.key]! += stat.value
                }
            }
        }

        state.player.combatLockDetails.actionLocked = true
        effects.append(
            Effect(value: .clearActionLock)
                .delay(for: .init(floatLiteral: tickUnit), scheduler: env.mainQueue)
                .eraseToEffect()
                .cancellable(id: ActionLockedCancelId.self, cancelInFlight: true)
        )
        return Effect.merge(effects)
    case .clearAnimation:
        state.player.combatLockDetails.animation = .none
    case .clearActionLock:
        state.player.combatLockDetails.actionLocked = false
    case let .presentItemPreview(item):
        state.currentPreviewingItem = item
    }
    return .none
}


struct InventoryView: View {
    let store: Store<InventoryState, InventoryAction>

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    func backgroundColor(for slot: InventorySlot, viewStore: ViewStore<InventoryState, InventoryAction>) -> Color {
        guard let item = slot.item else { return .uiButton }
        if case let .equipment(equipment) = item {
            if viewStore.player.canEquip(equipment) {
                return .uiButton
            } else {
                return .uiRed
            }
        } else {
            return .uiButton
        }
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(viewStore.player.inventory) { slot in

                        Button(action: {
                            viewStore.send(.inventorySlotTapped(slot), animation: .spring())
                        }) {
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(slot.item?.rarityColor?.opacity(0.6) ?? Color.uiBorder, lineWidth: 2)
                                .background(RoundedRectangle(cornerRadius: 4).fill(backgroundColor(for: slot, viewStore: viewStore).shadow(ShadowStyle.inner(color: .black, radius: 2, x: 0, y: 0))))
                                .frame(height: screen.height / 2.5 / 9)
                                .overlay {
                                    Text(slot.item?.icon ?? "")
                                        .font(.title)
                                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
                                }
                        }
                        .onDrag {
                            viewStore.send(.setCurrentDraggingSlot(slot))
                            return NSItemProvider(contentsOf: URL(string: "\(slot.id)")!)!
                        } preview: {
                            if let item = slot.item {
                                VStack {
                                    Text(item.name).font(.appFootnote).foregroundColor(.white)
                                    Text(item.icon).font(.largeTitle)
                                }
                            }
                        }
                        .onDrop(of: [.url], delegate: DropViewDelegate(store: store, slot: slot))
                        .contextMenu {
                            if let item = slot.item {

                                Text("\(item.icon) \(item.name)")

                                Button {
                                    viewStore.send(.presentItemPreview(item), animation: .default)
                                } label: {
                                    Label("Inspect", systemImage: "magnifyingglass")
                                }

                                Button {
                                    viewStore.send(.destroyItem(in: slot), animation: .default)
                                } label: {
                                    Label("Destroy", systemImage: "trash")
                                }
                            }
                        }
                    }
                }

                HStack {
                    ForEach(0..<5) { _ in
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(Color.uiBorder, lineWidth: 1)
                            .background(RoundedRectangle(cornerRadius: 4).fill(Color.uiButton))
                            .frame(height: screen.height / 2.5 / 9)
                            .overlay {
                                Image(systemName: "lock.fill")
                                    .font(.footnote)
                                    .foregroundColor(.black)
                            }
                            .opacity(0.5)
                    }
                }

                Button(action: {

                }) {
                    Label("Unlock more slots", systemImage: "lock.fill")
                        .font(.appFootnote)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.uiRed, in: Capsule())
                }
                .padding(.top, 4)
            }
        }
    }
}


struct DropViewDelegate: DropDelegate {
    let store: Store<InventoryState, InventoryAction>
    let slot: InventorySlot

    func performDrop(info: DropInfo) -> Bool {
        return true
    }

    func dropEntered(info: DropInfo) {
        let viewStore = ViewStore(store)

        let fromIndex = viewStore.player.inventory.firstIndex { slot in
            slot.id == viewStore.local.currentDraggingSlot?.id
        } ?? 0
        let toIndex = viewStore.player.inventory.firstIndex { slot in
            slot.id == self.slot.id
        } ?? 0

        if fromIndex != toIndex {
            let fromSlot = viewStore.player.inventory[fromIndex]
            viewStore.send(.handleInventorySwap(fromIndex: fromIndex, toIndex: toIndex, fromSlot: fromSlot), animation: .spring())
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
