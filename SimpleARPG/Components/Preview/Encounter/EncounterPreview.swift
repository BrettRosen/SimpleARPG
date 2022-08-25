//
//  EncounterPreview.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/21/22.
//

import SwiftUI

struct EncounterPreview: View {
    let encounter: Encounter
    var transparentBackground: Bool = false

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 8) {
            Text("Inventory")
                .font(.appCaption).bold()
                .foregroundColor(.white)

            InventoryGrid(
                inventory: encounter.monster.inventory,
                slotBackgroundColor: { _ in .uiButton },
                contextMenu: nil,
                dropDelegate: nil,
                inventorySlotTapped: nil,
                onDrag: nil
            )

            if !encounter.mods.isEmpty {

                Divider().frame(width: 100).overlay(Color.uiBorder)

                HStack {
                    Text("Modifiers")
                        .font(.appCaption).bold()
                        .foregroundColor(encounter.rarity.color)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                }

                VStack(alignment: .leading, spacing: 5) {
                    ForEach(encounter.mods) { mod in
                        Text(mod.displayName)
                            .font(.appCaption)
                            .foregroundColor(.white)
                    }
                }
                .opacity(0.75)
                .frame(height: isExpanded ? nil : 0, alignment: .top)
                .clipped()
            }
        }
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
}
