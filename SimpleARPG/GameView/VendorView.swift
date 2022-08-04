//
//  VendorView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/4/22.
//

import SwiftUI

struct VendorView: View {

    let vendor: Vendor

    @Namespace private var tabAnimation

    var body: some View {
        VStack(spacing: 12) {
            Text(vendor.icon) + Text(" Merchant " + vendor.name).font(.appFootnote).foregroundColor(.white)

            Divider()
                .frame(width: 150, height: 2)
                .overlay(Color.uiDarkBackground)

            HStack {
                TabView(tab: Vendor.TabType.weapons, selectedTab: vendor.selectedTab, namespace: tabAnimation) {

                }
                TabView(tab: Vendor.TabType.armor, selectedTab: vendor.selectedTab, namespace: tabAnimation) {

                }
                TabView(tab: Vendor.TabType.foodAndMisc, selectedTab: vendor.selectedTab, namespace: tabAnimation) {

                }
            }
            InventoryGrid(
                inventory: vendor.tabs[vendor.selectedTab]!,
                slotBackgroundColor: { slot in
                    .uiButton
                },
                contextMenu: { slot in
                    AnyView(Text(""))
                },
                dropDelegate: nil,
                inventorySlotTapped: { slot in

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

struct VendorView_Previews: PreviewProvider {
    static var previews: some View {
        VendorView(vendor: .init())
    }
}
