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
        VStack(spacing: 8) {
            Text(vendor.icon) + Text(" Vendor " + vendor.name).font(.appCallout).foregroundColor(.white)
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
        }
        .padding(8)
        .background(Color.uiBackground.cornerRadius(4))
    }
}

struct VendorView_Previews: PreviewProvider {
    static var previews: some View {
        VendorView(vendor: Vendor(name: "Johny", icon: "😄"))
    }
}
