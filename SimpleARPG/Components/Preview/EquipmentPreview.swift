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
        VStack(spacing: 5) {
            switch equipment.base {
            case let .weapon(weapon):
                if let special = weapon.identifiableWeaponBase.special {
                    Text("\(special.name)").font(.appFootnote).foregroundColor(.purple)
                }

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
            case let .armor(armor):
                ForEach(Array(equipment.base.stats.keys.sorted(by: { $0.displayName > $1.displayName }).enumerated()), id:\.element) { _, key in
                    if equipment.stats[key]! > 0 {
                        Text(key.displayName + ": ").font(.appFootnote).foregroundColor(.white) +
                        Text("\(equipment.stats[key]!, specifier: "%.2f")").font(.appFootnote).foregroundColor(.yellow)
                    }
                }

                Divider().frame(width: 100).overlay(Color.uiBorder)

                Text("Requires Level: ").font(.appFootnote).foregroundColor(.white.opacity(0.6))
                + Text("\(armor.identifiableEquipmentBase.levelRequirement), ").font(.appFootnote).foregroundColor(.white)
                + Text("\(Int(armor.identifiableEquipmentBase.strengthRequirement)) ").font(.appFootnote).foregroundColor(.white)
                + Text("Str, ").font(.appFootnote).foregroundColor(.white.opacity(0.6))
                + Text("\(Int(armor.identifiableEquipmentBase.dexterityRequirement)) ").font(.appFootnote).foregroundColor(.white)
                + Text("Dex, ").font(.appFootnote).foregroundColor(.white.opacity(0.6))
                + Text("\(Int(armor.identifiableEquipmentBase.intelligenceRequirement)) ").font(.appFootnote).foregroundColor(.white)
                + Text("Int").font(.appFootnote).foregroundColor(.white.opacity(0.6))
            }

            Divider().frame(width: 100).overlay(Color.uiBorder)

            ForEach(Array(equipment.nonBaseStats.keys.sorted(by: { $0.displayName > $1.displayName }).enumerated()), id:\.element) { _, key in
                Text(key.displayName + ": ").font(.appFootnote).foregroundColor(.white) +
                Text("\(equipment.stats[key]!, specifier: "%.2f")").font(.appFootnote).foregroundColor(.yellow)
            }
        }
    }
}
