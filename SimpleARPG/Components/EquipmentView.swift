//
//  EquipmentView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct EquipmentSlotView: View {
    var slot: EquipmentSlot
    var viewStore: ViewStore<GameState, GameAction>
    var size: CGSize

    private let unit: Double = 30

    var body: some View {
        Button(action: {
            guard let equipment = viewStore.player.allEquipment.first(where: { $0.base.slot == slot }) else { return }
            viewStore.send(.unequip(equipment), animation: .default)
        }) {
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(viewStore.player.allEquipment.first(where: { $0.base.slot == slot })?.rarity.color.opacity(0.6) ?? Color.uiBorder, lineWidth: 2)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.uiButton))
                .overlay {
                    Text(viewStore.player.allEquipment.first(where: { $0.base.slot == slot })?.icon ?? slot.icon)
                        .font(.title)
                        .opacity(viewStore.player.allEquipment.first(where: { $0.base.slot == slot }) == nil ? 0.2 : 1)
                        .if(viewStore.player.allEquipment.first(where: { $0.base.slot == slot }) != nil) { view in
                            view.shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 3)
                        }
                }
                .frame(maxWidth: unit * size.width, maxHeight: unit * size.height)
        }
    }
}

struct EquipmentView: View {
    let store: Store<GameState, GameAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(alignment: .bottom) {
                VStack {
                    HStack {
                        EquipmentSlotView(slot: .weapon, viewStore: viewStore, size: .init(width: 2, height: 4))
                        EquipmentSlotView(slot: .ring, viewStore: viewStore, size: .init(width: 1, height: 1))
                    }
                    EquipmentSlotView(slot: .gloves, viewStore: viewStore, size: .init(width: 2, height: 2))
                }

                VStack {
                    EquipmentSlotView(slot: .helmet, viewStore: viewStore, size: .init(width: 2, height: 2))
                    EquipmentSlotView(slot: .body, viewStore: viewStore, size: .init(width: 2, height: 4))
                    EquipmentSlotView(slot: .belt, viewStore: viewStore, size: .init(width: 2, height: 1))
                }

                VStack {
                    HStack {
                        EquipmentSlotView(slot: .amulet, viewStore: viewStore, size: .init(width: 1, height: 1))
                        EquipmentSlotView(slot: .offhand, viewStore: viewStore, size: .init(width: 2, height: 4))
                    }
                    EquipmentSlotView(slot: .boots, viewStore: viewStore, size: .init(width: 2, height: 2))
                }
            }
        }
    }
}

struct EquipmentView_Previews: PreviewProvider {
    static var previews: some View {
        EquipmentView(store: .init(initialState: .init(), reducer: gameReducer, environment: .live))
    }
}
