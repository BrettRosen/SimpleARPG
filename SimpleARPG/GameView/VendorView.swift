//
//  VendorView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/4/22.
//

import ComposableArchitecture
import SwiftUI

extension GameState {
    var vendorViewState: VendorState {
        get {
            VendorState(player: player, vendor: vendor)
        } set {
            player = newValue.player
            vendor = newValue.vendor
        }
    }
}

struct VendorState: Equatable {
    var player = Player()
    var vendor = Vendor()
}

enum VendorAction: Equatable {
    case vendorTapped
    case vendorTabTapped(Vendor.TabType)

    case buy(Item)
}

struct VendorEnvironment {

}

let vendorReducer: Reducer<VendorState, VendorAction, VendorEnvironment> = .init { state, action, env in
    switch action {
    case .vendorTapped:
        state.vendor.isActive.toggle()
    case let .vendorTabTapped(tab):
        state.vendor.selectedTab = tab
    case let .buy(item):

        if let coinsIndex = state.player.inventory.firstIndex(where: {
            if case .coins = $0.item { return true }
            return false
        }), case let .coins(coins) = state.player.inventory[coinsIndex].item,
            let purchasePrice = item.price?.buy,
            coins >= purchasePrice,
            let availableIndex = state.player.firstOpenInventorySlotIndex,
            let vendorIndex = state.vendor.tabs[state.vendor.selectedTab]?.firstIndex(where: { $0.item == item }) {

            state.player.inventory[coinsIndex].item = .coins(coins - purchasePrice)
            state.player.inventory[availableIndex].item = item

            state.vendor.tabs[state.vendor.selectedTab]?[vendorIndex].item = nil
        }
    }
    return .none
}

struct VendorView: View {

    let store: Store<VendorState, VendorAction>

    @State private var animating = false

    var body: some View {
        WithViewStore(store) { viewStore in
            Button(action: {
                viewStore.send(.vendorTapped)
            }) {
                VStack(spacing: 0) {
                    Text("💰")
                        .font(.system(size: 30))
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                        .offset(y: animating ? -5 : 10)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animating)

                    ZStack(alignment: .bottom) {
                        Circle()
                            .frame(width: animating ? 20 : 40, height: 40)
                            .foregroundColor(.black.opacity(0.8))
                            .blur(radius: animating ? 5 : 20)
                            .rotation3DEffect(.degrees(80), axis: (x: 1, y: 0, z: 0))
                            .offset(y: 20)
                            //.animation(Animation.linear(duration: 1).repeatForever(autoreverses: true), value: animating)

                        Text(viewStore.vendor.icon).font(.system(size: 42))
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                            .offset(y: animating ? 6 : 0)
                            //.animation(Animation.linear(duration: 1).repeatForever(autoreverses: true), value: animating)
                    }
                }
                .onAppear {
                    animating = true
                }
            }
        }
    }
}

struct VendorInventoryView: View {

    let store: Store<VendorState, VendorAction>

    @Namespace private var tabAnimation

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 12) {
                Text(viewStore.vendor.icon) + Text(" Merchant " + viewStore.vendor.name).font(.appFootnote).foregroundColor(.white)

                Divider()
                    .frame(width: 150, height: 2)
                    .overlay(Color.uiDarkBackground)

                HStack {
                    TabView(tab: Vendor.TabType.weapons, selectedTab: viewStore.vendor.selectedTab, namespace: tabAnimation) {
                        viewStore.send(.vendorTabTapped(.weapons))
                    }
                    TabView(tab: Vendor.TabType.armor, selectedTab: viewStore.vendor.selectedTab, namespace: tabAnimation) {
                        viewStore.send(.vendorTabTapped(.armor))
                    }
                    TabView(tab: Vendor.TabType.foodAndMisc, selectedTab: viewStore.vendor.selectedTab, namespace: tabAnimation) {
                        viewStore.send(.vendorTabTapped(.foodAndMisc))
                    }
                }
                InventoryGrid(
                    inventory: viewStore.vendor.tabs[viewStore.vendor.selectedTab]!,
                    slotBackgroundColor: { slot in
                        .uiButton
                    },
                    contextMenu: { slot in
                        guard let item = slot.item, let price = item.price else { return AnyView(EmptyView())}
                        return AnyView(
                            Button {
                                viewStore.send(.buy(item))
                            } label: {
                                Text("Buy for \(price.buy) 🪙")
                            }
                        )
                    },
                    dropDelegate: nil,
                    inventorySlotTapped: { slot in
                        guard let item = slot.item else { return }

                    },
                    onDrag: nil
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Tap to inspect. Tap and hold to purchase.")
                        .font(.appCaption)
                        .foregroundColor(.white.opacity(0.6))
                    Text("Tap and hold your items to sell.")
                        .font(.appCaption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(12)
            .background(Color.uiBackground.cornerRadius(4))
        }
    }
}
