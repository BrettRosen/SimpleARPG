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

    /// Passes the weapon in as both it's WeaponBase AND Equipment type so that we can
    /// access the nonbase stats on Equipment type
    func damageRangeString(from weapon: WeaponBase, equipment: Equipment) -> String {
        var weaponDamageRangeLow = weapon.identifiableWeaponBase.damage.lowerBound
        var weaponDamageRangeHigh = weapon.identifiableWeaponBase.damage.upperBound

        switch weapon.identifiableWeaponBase.damageType {
        case .melee, .ranged:
            if let flatPhysical = equipment.nonBaseStats[.flatPhysical] {
                weaponDamageRangeLow += flatPhysical
                weaponDamageRangeHigh += flatPhysical
            }
            if let percentPhysical = equipment.nonBaseStats[.percentPhysical] {
                weaponDamageRangeLow *= (1 + percentPhysical)
                weaponDamageRangeHigh *= (1 + percentPhysical)
            }
        case let .magic(type):
            switch type {
            case .fire:
                break
            case .cold:
                break
            case .lightning:
                break
            }
        }
        return "\(Int(weaponDamageRangeLow))...\(Int(weaponDamageRangeHigh))"
    }

    var body: some View {
        VStack(spacing: 5) {
            switch equipment.base {
            case let .weapon(weapon):
                if let special = weapon.identifiableWeaponBase.special {
                    Text("\(special.name)").font(.appFootnote).foregroundColor(.purple)
                }

                VStack(spacing: 5) {
                    Text("\(weapon.identifiableWeaponBase.damageType.name): ").font(.appFootnote).foregroundColor(.white.opacity(0.6)) +
                    Text(damageRangeString(from: weapon, equipment: equipment)).font(.appFootnote).foregroundColor(.white)

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
                Text(displayString(for: key, value: equipment.stats[key]!)).font(.appFootnote).foregroundColor(.yellow)
            }
        }
    }

    func displayString(for statKey: Stat.Key, value: Double) -> String {
        switch statKey.displayType {
        case .int:
            return "\(Int(value))"
        case .double:
            return "%" + String(format: "%.2f", value * 100)
        }
    }
}
