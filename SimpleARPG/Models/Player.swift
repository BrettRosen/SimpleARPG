//
//  Player.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import BetterCodable
import Foundation

func experienceNeededForLevel(_ level: Int) -> Double {
    let p1: Double = Double(level) - 1
    let p2 = 300 * pow(2, Double(level)-1/6)
    return (p1 + p2) / 4
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
    var damagePerAttack: [Damage] { get }
    var combatDetails: CombatDetails { get set }
    var damageLog: [DamageLogEntry] { get set }
    var currentMessage: Message? { get set }
    var specialResource: Int { get set }
}

struct CombatDetails: Equatable, Codable {
    var animation: PlayerAnimation = .none
    var animationEffectCancelId = UUID()

    var actionLocked: Bool = false

    var queuedSpecialAttack: SpecialAttack?

    var isSpecialAttacking: Bool { animation == .specialAttacking }
    var isAttacking: Bool { animation == .attacking }
    var isEating: Bool {
        if case .eating = animation { return true }
        return false
    }
}

enum PlayerAnimation: Equatable, Codable {
    case eating(Food)
    case attacking
    case specialAttacking
    case none
}

struct PlayerIcon: Equatable, Codable {
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

struct Player: Equatable, Codable, PlayerIdentifiable {
    var playerId: Int = UUID().hashValue

    static let flatMaxLifePerLevel = 12

    /// Used for initializing base stats. All other stat increases from
    /// Equipment, Leveling, Debuffs, etc. will happen at the reducer level
    init() {
        self.stats = baseStats()
        self.currentLife = 0
        self.currentLife = maxLife

        self.inventory[0].item = .equipment(.generateEquipment(level: 1, slot: .weapon, incRarity: 10))
        self.inventory[1].item = .equipment(Equipment(base: .weapon(.bow(.crudeBow)), rarity: .rare, stats: [:]))
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

    @CodableIgnored<DefaultCombatDetailsStrategy>
    var combatDetails: CombatDetails = .init()
    var isDead: Bool { currentLife <= 0 }

    @CodableIgnored<DefaultEmptyArrayStrategy>
    var damageLog: [DamageLogEntry] = []

    var allEquipment = [Equipment]()
    var inventory: [InventorySlot] = [
        .init(), .init(), .init(), .init(),
        .init(item: .shrimp), .init(item: .shrimp), .init(item: .shrimp), .init(item: .shrimp),
        .init(), .init(), .init(), .init(),
        .init(), .init(), .init(), .init(),
        .init(), .init(), .init(), .init(),
        .init(), .init(), .init(), .init(),
    ]

    var firstOpenInventorySlotIndex: Int? {
        inventory.firstIndex(where: { $0.item == nil })
    }

    var specialResource: Int = 100
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
        return !isDead && combatDetails.animation == .none
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

    var damagePerAttack: [Damage] {
        guard let weapon = weapon else { return [] }
        let baseDamageRange = weapon.identifiableWeaponBase.damage
        let flatDamage = stats[.flatPhysical]!
        let percentIncreaseFromStrength = 1 + ((stats[.strength]! / 10) * 0.02)
        let critChance = weapon.identifiableWeaponBase.critChance
        var baseDamage = (Double.random(in: baseDamageRange) + flatDamage) * percentIncreaseFromStrength
        if Double.random(in: 0...1.0) <= critChance {
            baseDamage *= 2
        }

        let rawAmount = stats[.percentHitChance]! <= Double.random(in: 0.0...1.0) ? 0 : baseDamage

        var damages: [Damage] = []
        let weaponDamage = Damage(type: weapon.identifiableWeaponBase.damageType, rawAmount: rawAmount)
        damages.append(weaponDamage)

        if let coldDamage = stats[.flatCold], coldDamage > 0 {
            let damage = Damage(type: .magic(.cold), rawAmount: coldDamage, secondary: true)
            damages.append(damage)
        }
        if let fireDamage = stats[.flatFire], fireDamage > 0 { 
            let damage = Damage(type: .magic(.fire), rawAmount: fireDamage, secondary: true)
            damages.append(damage)
        }
        if let lightningDamage = stats[.flatLightning], lightningDamage > 0 {
            let damage = Damage(type: .magic(.lightning), rawAmount: lightningDamage, secondary: true)
            damages.append(damage)
        }
        return damages
    }

    @CodableIgnored<DefaultNilStrategy>
    var currentMessage: Message?
}
