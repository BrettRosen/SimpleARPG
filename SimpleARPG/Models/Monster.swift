//
//  Monster.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/12/22.
//

import Foundation
import SwiftUI

/// Defines items that can drop from mobs.
/// This is different than Item since we don't want the associted type
enum ItemDrop: Equatable {
    case equipment, food, encounter, nothing
}

struct LootTable: Equatable {
    struct LootDrop: Equatable {
        var item: ItemDrop // To indicate a drop can also be... nothing
        var weight: Int
    }

    var drops: [LootDrop]
}

struct Monster: Equatable, PlayerIdentifiable {
    var playerId: Int = UUID().hashValue

    static let baseDropChance = 0.16

    let icon: String
    let name: String
    let level: Int
    var stats: [Stat.Key: Double]
    var lootTable: LootTable = .init(drops: [
        .init(item: .equipment, weight: 8),
        .init(item: .food, weight: 24),
        .init(item: .encounter, weight: 4),
        .init(item: .nothing, weight: 64)
    ])

    init(icon: String, name: String, level: Int, stats: [Stat.Key : Double]) {
        self.icon = icon
        self.name = name
        self.level = level
        self.stats = stats

        self.stats[.flatMaxLife] = Double(level) * 10
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

    var inventory: [InventorySlot] = [.init(item: .food(.shrimp)), .init(item: .food(.shrimp)), .init(item: .food(.shrimp))]

    var baseDamage: Double { Monster.baseDamage(level: level) }

    static func baseDamage(level: Int) -> Double {
        0.0015 * pow(Double(level), 3) + 0.2 * Double(level) + 6
    }

    var canAttack: Bool {
        !isDead && combatLockDetails.animation == .none
    }

    // TODO: This needs to be based off the monster's Weapon
    var ticksPerAttack: Int {
        4
    }

    var damagePerAttack: Double {
        let flatDamage = stats[.flatPhysical] ?? 0
        let percentIncreaseFromStrength = 1 + ((stats[.strength] ?? 0 / 10) * 0.02)
        let baseDamage = (baseDamage + flatDamage) * percentIncreaseFromStrength
        return baseDamage
    }
}
