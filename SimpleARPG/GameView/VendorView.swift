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
            VendorState(player: player, vendors: vendors, currentPreviewingItem: currentPreviewingItem)
        } set {
            player = newValue.player
            vendors = newValue.vendors
            currentPreviewingItem = newValue.currentPreviewingItem
        }
    }
}

struct VendorState: Equatable {
    var player = Player()
    var vendors: [Vendor] = []
    var itemVendor: Vendor = .init()
    var encounterVendor: Vendor = .init()
    var currentPreviewingItem: Item?
}

enum VendorAction: Equatable {
    case vendorTapped(Vendor)
    case vendorDismissed(Vendor)
    case vendorTabTapped(Vendor, Vendor.TabType)

    case buy(Vendor, Item)
    case itemTapped(Item)
}

struct VendorEnvironment {

}


let vendorReducer: Reducer<VendorState, VendorAction, VendorEnvironment> = .init { state, action, env in
    func attemptBuy(from vendor: inout Vendor, item: Item) {
        if let coinsIndex = state.player.inventory.firstIndex(where: {
            if case .coins = $0.item { return true }
            return false
        }), case let .coins(coins) = state.player.inventory[coinsIndex].item,
            let purchasePrice = item.price?.buy,
            coins >= purchasePrice,
            let availableIndex = state.player.firstOpenInventorySlotIndex,
            let vendorIndex = vendor.tabs[vendor.selectedTab]?.firstIndex(where: { $0.item == item }) {

            state.player.inventory[coinsIndex].item = .coins(coins - purchasePrice)
            state.player.inventory[availableIndex].item = item

            vendor.tabs[vendor.selectedTab]?[vendorIndex].item = nil
        }
    }

    func vendorIndex(from vendor: Vendor) -> Int? {
        state.vendors.firstIndex(where: { vendor.id == $0.id })
    }

    switch action {
    case let .vendorTapped(vendor):
        guard let index = vendorIndex(from: vendor) else { return .none }
        state.vendors[index].isActive = true
    case let .vendorDismissed(vendor):
        guard let index = vendorIndex(from: vendor) else { return .none }
        state.vendors[index].isActive = false
    case let .vendorTabTapped(vendor, tab):
        guard let index = vendorIndex(from: vendor) else { return .none }
        state.vendors[index].selectedTab = tab
    case let .itemTapped(item):
        state.currentPreviewingItem = item
    case let .buy(vendor, item):
        guard let index = vendorIndex(from: vendor) else { return .none }
        attemptBuy(from: &state.vendors[index], item: item)
    }
    return .none
}

struct VendorView: View {

    let vendor: Vendor
    let store: Store<VendorState, VendorAction>

    @State private var animating = false

    var body: some View {
        if vendor.tabs.isEmpty {
            EmptyView()
        } else {
            WithViewStore(store) { viewStore in
                ZStack(alignment: .bottom) {
                    Text("🛖").font(.system(size: 80)).opacity(0.75)
                    Button(action: {
                        viewStore.send(.vendorTapped(vendor))
                    }) {
                        VStack(spacing: 4) {

                            VStack(spacing: 4) {
                                Text("🪙")
                                    .font(.system(size: 22))

                                VStack(spacing: 2) {
                                    Text(vendor.type.name)
                                        .font(.appCaption)
                                        .foregroundColor(.white)
                                    Text(vendor.type.title)
                                        .font(.appCaption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding(5)
                                .background(Color.uiBackground, in: RoundedRectangle(cornerRadius: 4))

                            }
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

                                Text(vendor.type.icon).font(.system(size: 46))
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
    }
}

struct VendorInventoryView: View {

    let vendor: Vendor
    let store: Store<VendorState, VendorAction>

    @Namespace private var tabAnimation

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .topTrailing) {
                Button(action: {
                    viewStore.send(.vendorDismissed(vendor))
                }) {
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }

                VStack(spacing: 12) {
                    Text(vendor.selectedTab.name).font(.appFootnote).foregroundColor(.white)

                    Divider()
                        .frame(width: 150, height: 2)
                        .overlay(Color.uiDarkBackground)

                    HStack {
                        ForEach(Array(vendor.tabs.keys.sorted(by: { $0.name > $1.name }).enumerated()), id:\.element) { _, key in
                            TabView(tab: key, selectedTab: vendor.selectedTab, namespace: tabAnimation) {
                                viewStore.send(.vendorTabTapped(vendor, key))
                            }
                        }
                    }

                    if let inventory = vendor.tabs[vendor.selectedTab] {
                        InventoryGrid(
                            inventory: inventory,
                            slotBackgroundColor: { slot in
                                .uiButton
                            },
                            contextMenu: { slot in
                                guard let item = slot.item, let price = item.price else { return AnyView(EmptyView())}
                                return AnyView(
                                    Button {
                                        viewStore.send(.buy(vendor, item))
                                    } label: {
                                        Text("Buy for \(price.buy) 🪙")
                                    }
                                )
                            },
                            dropDelegate: nil,
                            inventorySlotTapped: { slot in
                                guard let item = slot.item else { return }
                                viewStore.send(.itemTapped(item))
                            },
                            onDrag: nil
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tap to inspect. Tap and hold to purchase.")
                            .font(.appCaption)
                            .foregroundColor(.white.opacity(0.6))
                        Text("Tap and hold your items to sell.")
                            .font(.appCaption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(12)
            .background {
                Color.uiBackground.cornerRadius(4)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
            }
        }
    }
}
