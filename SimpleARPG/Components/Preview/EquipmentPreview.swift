//
//  EquipmentPreview.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/12/22.
//

import Foundation
import SwiftUI

struct EquipmentPreview: View {

    let equipment: Equipment

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 5) {
                Text("🪙 \(equipment.price.sell)")
                    .font(.appFootnote)
                    .foregroundColor(.white)
                    .padding(.bottom, 6)

                Text("Some Unique Name".uppercased())
                    .font(.appCallout)
                    .bold()
                    .foregroundColor(equipment.rarity.color)
                Text(equipment.name.uppercased())
                    .font(.appCallout)
                    .bold()
                    .foregroundColor(equipment.rarity.color)

                Divider().frame(width: 100).overlay(Color.uiBorder)

                switch equipment.base {
                case let .weapon(weapon):
                    VStack(spacing: 5) {
                        Text("Physical Damage: ").font(.appFootnote).foregroundColor(.white.opacity(0.6)) +
                        Text("\(Int(weapon.identifiableWeaponBase.damage.lowerBound))...\(Int(weapon.identifiableWeaponBase.damage.upperBound))").font(.appFootnote).foregroundColor(.white)

                        Text("Critical Strike Chance: ").font(.appFootnote).foregroundColor(.white.opacity(0.6)) +
                        Text("\(Int(weapon.identifiableWeaponBase.critChance * 100))%").font(.appFootnote).foregroundColor(.white)

                        Text("Ticks Per Attack: ").font(.appFootnote).foregroundColor(.white.opacity(0.6)) +
                        Text("\(weapon.identifiableWeaponBase.ticksPerAttack)").font(.appFootnote).foregroundColor(.white)
                    }

                    Divider().frame(width: 100).overlay(Color.uiBorder)

                    Text("Requires Level: ").font(.appFootnote).foregroundColor(.white.opacity(0.6))
                    + Text("\(weapon.identifiableEquipmentBase.levelRequirement), ").font(.appFootnote).foregroundColor(.white)
                    + Text("\(Int(weapon.identifiableEquipmentBase.strengthRequirement)) ").font(.appFootnote).foregroundColor(.white)
                    + Text("Str, ").font(.appFootnote).foregroundColor(.white.opacity(0.6))
                    + Text("\(Int(weapon.identifiableEquipmentBase.dexterityRequirement)) ").font(.appFootnote).foregroundColor(.white)
                    + Text("Dex, ").font(.appFootnote).foregroundColor(.white.opacity(0.6))
                    + Text("\(Int(weapon.identifiableEquipmentBase.intelligenceRequirement)) ").font(.appFootnote).foregroundColor(.white)
                    + Text("Int").font(.appFootnote).foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding()
        .buttonStyle(PlainButtonStyle())
        .background(Color.uiBackground)
        .cornerRadius(2)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
    }
}
