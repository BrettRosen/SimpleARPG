//
//  Player.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import Foundation

func experienceNeededForLevel(_ level: Int) -> Double {
    pow(Double(level)/0.07, 2)
}

func getLevelFromExperience(_ exp: Double) -> Int {
    Int(0.07 * sqrt(exp))
}

protocol PlayerIdentifiable {
    // Used for the CombatClient
    var playerId: Int { get }
    var icon: PlayerIcon { get set }
    var maxLife: Double { get }
    var currentLife: Double { get set }
    var weapon: WeaponBase? { get }
    var allEquipment: [Equipment] { get set }
    var inventory: [InventorySlot] { get set }
    var damagePerAttack: Damage { get }
    var combatLockDetails: CombatLockDetails { get set }
    var isAttacking: Bool { get }
    var isEating: Bool { get }
}

struct CombatLockDetails: Equatable {
    var animation: PlayerAnimation = .none
    var animationEffectCancelId = UUID()

    var actionLocked: Bool = false
}

enum PlayerAnimation: Equatable {
    case eating(Food)
    case attacking
    case none
}

struct PlayerIcon: Equatable {
    var asset: String
    /// 1 or -1 depending on Player or Monster
    var xScale: CGFloat
}

func baseStats() -> [Stat.Key: Double] {
    var stats: [Stat.Key: Double] = [:]
    for stat in Stat.baseDefensiveStats {
        stats[stat.key] = stat.value
    }
    for stat in Stat.baseOffensiveStats {
        stats[stat.key] = stat.value
    }
    for stat in Stat.baseMiscStats {
        stats[stat.key] = stat.value
    }
    return stats
}

struct Player: Equatable, PlayerIdentifiable {
    var playerId: Int = UUID().hashValue

    static let flatMaxLifePerLevel = 12

    /// Used for initializing base stats. All other stat increases from
    /// Equipment, Leveling, Debuffs, etc. will happen at the reducer level
    init() {
        self.stats = baseStats()
        self.currentLife = 0
        self.currentLife = maxLife
    }

    var level: Int = 1
    var icon: PlayerIcon = .init(asset: "😡", xScale: 1)
    var totalExperience: Double = 0
    var currentLevelExperience: Double = 0
    var expForNextLevel: Double {
        experienceNeededForLevel(level + 1) - experienceNeededForLevel(level)
    }

    var stats: [Stat.Key: Double]

    var currentLife: Double
    var maxLife: Double {
        let beforeApplyingPercentInc = stats[.flatMaxLife]! + (stats[.strength]!/10 * 5)
        return beforeApplyingPercentInc * (1 + stats[.percentMaxLife]!)
    }

    var combatLockDetails: CombatLockDetails = .init()
    var isDead: Bool { currentLife <= 0 }
    var isAttacking: Bool { combatLockDetails.animation == .attacking }
    var isEating: Bool {
        if case .eating = combatLockDetails.animation { return true }
        return false
    }

    var allEquipment = [Equipment]()
    var inventory: [InventorySlot] = [
        .init(item: .shrimp), .init(item: .stoneAxeMock), .init(item: .crudeBowMock), .init(),
        .init(item: .shrimp), .init(item: .shrimp), .init(item: .shrimp), .init(item: .shrimp),
        .init(), .init(), .init(), .init(),
        .init(), .init(), .init(), .init(),
        .init(), .init(), .init(), .init(),
        .init(), .init(), .init(), .init(),
    ]

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

    var canAttack: Bool {
        guard let _ = weapon else { return false }
        return !isDead && combatLockDetails.animation == .none
    }

    var ticksPerAttack: Int {
        guard let weapon = weapon else { return .max }
        return weapon.identifiableWeaponBase.ticksPerAttack
    }

    func canEquip(_ equipment: Equipment) -> Bool {
        level >= equipment.base.levelRequirement
            && stats[.strength]! >= equipment.base.strengthRequirement
            && stats[.dexterity]! >= equipment.base.dexterityRequirement
            && stats[.intelligence]! >= equipment.base.intelligenceRequirement
    }

    var damagePerAttack: Damage {
        guard let weapon = weapon else { return .init(type: .melee, rawAmount: 0) }
        let baseDamageRange = weapon.identifiableWeaponBase.damage
        let flatDamage = stats[.flatPhysical]!
        let percentIncreaseFromStrength = 1 + ((stats[.strength]! / 10) * 0.02)
        let critChance = weapon.identifiableWeaponBase.critChance
        var baseDamage = (Double.random(in: baseDamageRange) + flatDamage) * percentIncreaseFromStrength
        if Double.random(in: 0...1.0) <= critChance {
            baseDamage *= 2
        }
        return Damage(type: weapon.identifiableWeaponBase.damageType, rawAmount: baseDamage)
    }
}
