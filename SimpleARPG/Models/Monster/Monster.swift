//
//  Monster.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/12/22.
//

import Foundation
import SwiftUI

struct LootTable: Equatable {
    struct LootDrop: Equatable {
        var item: ItemDrop // To indicate a drop can also be... nothing
        var weight: Int
    }

    var drops: [LootDrop]

    static var `default`: LootTable = .init(drops: [
        .init(item: .equipment, weight: 24),
        .init(item: .food, weight: 11),
        .init(item: .encounter, weight: 32),
        .init(item: .nothing, weight: 33)
    ])
}

struct Monster: Equatable, PlayerIdentifiable {
    var playerId: Int = UUID().hashValue

    static let maxInventorySlots = 24
    /// Defines the maximum amount of random items that can be
    /// generated for a monster after required items (food).
    static let maxRandomInventoryItem = 4
    static let maxFoodCountRange = 5...10

    var icon: PlayerIcon
    let name: String
    let level: Int
    var stats: [Stat.Key: Double]

    init(
        icon: PlayerIcon,
        name: String,
        level: Int,
        stats: [Stat.Key : Double],
        inventory: [InventorySlot],
        equipment: [Equipment]
    ) {
        self.icon = icon
        self.name = name
        self.level = level
        self.inventory = inventory
        self.allEquipment = equipment

        self.stats = baseStats()

        for stat in stats {
            self.stats[stat.key]! = stat.value
        }

        self.currentLife = 0
        self.currentLife = maxLife
    }

    var currentLife: Double
    var maxLife: Double {
        var maxLife = stats[.flatMaxLife]!

        if let strength = stats[.strength] {
            maxLife += (strength/10 * 5)
        }
        if let percentMaxLife = stats[.percentMaxLife] {
            maxLife *= (1 + percentMaxLife)
        }

        return maxLife
    }

    var combatLockDetails: CombatLockDetails = .init()
    var isDead: Bool { currentLife <= 0 }
    var isAttacking: Bool { combatLockDetails.animation == .attacking }
    var isEating: Bool {
        if case .eating = combatLockDetails.animation { return true }
        return false
    }

    var damageLog: [DamageLogEntry] = []

    var allEquipment = [Equipment]()
    var inventory: [InventorySlot]

    var firstOpenInventorySlotIndex: Int? {
        inventory.firstIndex(where: { $0.item == nil })
    }

    var weapon: WeaponBase? {
        let equipment = allEquipment.first(where: {
            if case .weapon(_) = $0.base { return true }
            return false
        })
        guard case let .weapon(weapon) = equipment?.base else { return nil }
        return weapon
    }

    var baseDamage: Double { Monster.baseDamage(level: level) }

    static func baseDamage(level: Int) -> Double {
        0.0015 * pow(Double(level), 1.2) + 0.2 * Double(level) + 6
    }

    var canAttack: Bool {
        !isDead && combatLockDetails.animation == .none
    }

    var ticksPerAttack: Int {
        guard let weapon = weapon else { return .max }
        return weapon.identifiableWeaponBase.ticksPerAttack
    }

    var damagePerAttack: Damage {
        guard let weapon = weapon else { return .init(type: .melee, rawAmount: 0) }
        let baseDamageRange = weapon.identifiableWeaponBase.damage
        let flatDamage = stats[.flatPhysical] ?? 0
        let percentIncreaseFromStrength = 1 + ((stats[.strength]! / 10) * 0.02)
        let critChance = weapon.identifiableWeaponBase.critChance
        var baseDamage = (Double.random(in: baseDamageRange) + flatDamage + Monster.baseDamage(level: level)) * percentIncreaseFromStrength
        if Double.random(in: 0...1.0) <= critChance {
            baseDamage *= 2
        }

        let rawAmount = stats[.percentHitChance]! <= Double.random(in: 0.0...1.0) ? 0 : baseDamage
        return Damage(type: weapon.identifiableWeaponBase.damageType, rawAmount: rawAmount)
    }

    var currentMessage: Message?
}
