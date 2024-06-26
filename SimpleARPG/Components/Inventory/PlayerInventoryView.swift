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
            InventoryState(local: inventoryLocalState, player: player, vendors: vendors, previewingEncounter: previewingEncounter, currentPreviewingItem: currentPreviewingItem)
        } set {
            inventoryLocalState = newValue.local
            player = newValue.player
            vendors = newValue.vendors
            previewingEncounter = newValue.previewingEncounter
            currentPreviewingItem = newValue.currentPreviewingItem
        }
    }
}

struct InventoryLocalState: Equatable, Codable {
    var currentDraggingSlot: InventorySlot?
}

struct PreviewingEncounter: Equatable, Codable {
    var encounter: Encounter
    var slot: InventorySlot
}

struct InventoryState: Equatable {
    var local: InventoryLocalState = .init()
    var player: Player = .init()
    var vendors: [Vendor] = []
    var previewingEncounter: PreviewingEncounter?
    var currentPreviewingItem: Item?
}

enum InventoryAction: Equatable {
    case inventorySlotTapped(InventorySlot)
    case destroyItem(in: InventorySlot)
    case setCurrentDraggingSlot(InventorySlot)
    case handleInventorySwap(fromIndex: Int, toIndex: Int, fromSlot: InventorySlot)
    case presentItemPreview(Item)

    case sell(Item)

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
              !state.player.combatDetails.actionLocked
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
                    .cancellable(id: state.player.combatDetails.animationEffectCancelId)
            )
        case let .equipment(equipment):
            guard state.player.canEquip(equipment) else { return .none }

            // If we already have an item of that type equipped...
            if let existingEquipment = state.player.allEquipment.first(where: { $0.base.slot == equipment.base.slot }) {

                state.player.allEquipment.removeAll(where: { $0.base.slot == existingEquipment.base.slot })
                state.player.allEquipment.append(equipment)
                state.player.inventory[index].item = .equipment(existingEquipment)

                for stat in existingEquipment.stats {
                    state.player.stats[stat.key]! -= stat.value
                }
                for stat in equipment.stats {
                    state.player.stats[stat.key]! += stat.value
                }
            } else {
                state.player.allEquipment.append(equipment)
                state.player.inventory[index].item = nil
                state.player.stats.merge(equipment.stats, uniquingKeysWith: +)
            }
        case .coins:
            break
        }

        state.player.combatDetails.actionLocked = true
        effects.append(
            Effect(value: .clearActionLock)
                .delay(for: .init(floatLiteral: tickUnit), scheduler: env.mainQueue)
                .eraseToEffect()
                .cancellable(id: ActionLockedCancelId.self, cancelInFlight: true)
        )
        return Effect.merge(effects)
    case let .sell(item):
        if let itemIndex = state.player.inventory.firstIndex(where: { $0.item == item }) {
            state.player.inventory[itemIndex].item = nil

            if let coinsIndex = state.player.inventory.firstIndex(where: {
                if case .coins = $0.item { return true }
                return false
            }), case let .coins(coins) = state.player.inventory[coinsIndex].item {
                state.player.inventory[coinsIndex].item = .coins(coins + item.price!.sell)
            } else if let emptyIndex = state.player.firstOpenInventorySlotIndex {
                state.player.inventory[emptyIndex].item = .coins(item.price!.sell)
            }
        }
    case .clearAnimation:
        state.player.combatDetails.animation = .none
    case .clearActionLock:
        state.player.combatDetails.actionLocked = false
    case let .presentItemPreview(item):
        state.currentPreviewingItem = item
    }
    return .none
}


struct PlayerInventoryView: View {
    let store: Store<InventoryState, InventoryAction>

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
            VStack(spacing: 8) {
                InventoryGrid(
                    inventory: viewStore.player.inventory,
                    slotBackgroundColor: { slot in
                        backgroundColor(for: slot, viewStore: viewStore)
                    },
                    contextMenu: { slot in
                        guard let item = slot.item else { return AnyView(EmptyView()) }
                        return AnyView(VStack {
                            Text("\(item.icon) \(item.name)")

                            if viewStore.vendors.contains(where: { $0.isActive }), let price = item.price {
                                Button {
                                    viewStore.send(.sell(item))
                                } label: {
                                    Text("Sell for \(price.sell) 🪙")
                                }
                            } else if let price = item.price {
                                Text("\(price.sell) 🪙")
                            }

                            Button {
                                viewStore.send(.presentItemPreview(item), animation: .default)
                            } label: {
                                Label("Inspect", systemImage: "magnifyingglass")
                            }

                            Button(role: .destructive) {
                                viewStore.send(.destroyItem(in: slot), animation: .default)
                            } label: {
                                Label("Destroy", systemImage: "trash")
                            }
                        })
                    },
                    dropDelegate: { slot in
                        DropViewDelegate(store: store, slot: slot)
                    },
                    inventorySlotTapped: { slot in
                        viewStore.send(.inventorySlotTapped(slot), animation: .spring())
                    },
                    onDrag: { slot in
                        viewStore.send(.setCurrentDraggingSlot(slot))
                    }
                )
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
