//
//  ItemPreview.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct ItemPreview: View {
    var item: Item
    var body: some View {

        VStack {
            if let price = item.price {
                Text("🪙 \(price.sell)")
                    .font(.appFootnote)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 6)
            }

            HStack(spacing: 12) {
                Text(item.icon).font(.title2)
                    .padding(8)
                    .background(Color.uiDarkBackground, in: RoundedRectangle(cornerRadius: 2))
                VStack(spacing: 5) {
                    Text(item.name.uppercased())
                        .font(.appCallout)
                        .bold()
                        .foregroundColor(item.rarityColor ?? .white)
                }
            }

            Divider().frame(width: 100).overlay(Color.uiBorder)

            switch item {
            case .food, .coins:
                EmptyView()
            case let .equipment(equipment):
                EquipmentPreview(equipment: equipment)
            case let .encounter(encounter):
                EncounterPreview(encounter: encounter)
            }
        }
        .padding()
        .buttonStyle(PlainButtonStyle())
        .background(Color.uiBackground)
        .cornerRadius(2)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
    }
}

struct ItemPreview_Previews: PreviewProvider {
    static var previews: some View {
        ItemPreview(item: .equipment(.generateEquipment(level: 1, slot: .weapon, incRarity: 0)))
    }
}
