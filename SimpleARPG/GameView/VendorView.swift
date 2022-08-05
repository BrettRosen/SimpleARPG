//
//  VendorView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/4/22.
//

import SwiftUI

struct VendorView: View {

    let vendor: Vendor
    let onTap: () -> Void

    @State private var animating = false

    var body: some View {
        Button(action: {
            onTap()
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

                    Text(vendor.icon).font(.system(size: 42))
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

struct VendorInventoryView: View {

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

struct VendorInventoryView_Previews: PreviewProvider {
    static var previews: some View {
        VendorInventoryView(vendor: .init())
    }
}
