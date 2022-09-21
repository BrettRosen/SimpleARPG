//
//  Stats.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/13/22.
//

import Foundation

struct AffixPool: Equatable, Codable {
    var prefix: [Stat.Key]
    var suffix: [Stat.Key]
}

enum Stat: Equatable, Codable {

    enum Key: String, Codable {
        case armour
        case percentArmour
        case flatMaxLife
        case percentMaxLife
        case flatMaxMana
        case percentMaxMana
        case lifeRegen
        case fireRes
        case coldRes
        case lightningRes
        case strength
        case dexterity
        case intelligence
        case percentPhysical
        case flatPhysical
        case flatCold
        case flatFire
        case flatLightning
        case percentHitChance
        case incItemRarity
        case incItemQuantity

        enum DisplayType {
            case int, double
        }

        var displayType: DisplayType {
            switch self {
            case .armour: return .int
            case .percentArmour: return .double
            case .flatMaxLife: return .int
            case .percentMaxLife: return .double
            case .flatMaxMana: return .int
            case .percentMaxMana: return .double
            case .lifeRegen: return .int
            case .fireRes: return .int
            case .coldRes: return .int
            case .lightningRes: return .int
            case .strength: return .int
            case .dexterity: return .int
            case .intelligence: return .int
            case .percentPhysical: return .double
            case .flatPhysical: return .int
            case .flatCold: return .int
            case .flatFire: return .int
            case .flatLightning: return .int
            case .percentHitChance: return .double
            case .incItemRarity: return .int
            case .incItemQuantity: return .int
            }
        }

        var displayName: String {
            switch self {
            case .armour: return "Armour"
            case .percentArmour: return "%Inc Armour"
            case .flatMaxLife: return "Max Life"
            case .percentMaxLife: return "%Inc Life"
            case .flatMaxMana: return "Max Mana"
            case .percentMaxMana: return "%Inc Mana"
            case .lifeRegen: return "Life regen per tick"
            case .fireRes: return "Fire Resistance"
            case .coldRes: return "Cold Resistance"
            case .lightningRes: return "Lightning Resistance"
            case .strength: return "Strength"
            case .dexterity: return "Dexterity"
            case .intelligence: return "Intelligence"
            case .percentPhysical: return "%Inc Physical"
            case .flatPhysical: return "🗡 Added Physical"
            case .flatCold: return "❄️ Added Cold"
            case .flatFire: return "🔥 Added Fire"
            case .flatLightning: return "⚡️ Added Lightning"
            case .percentHitChance: return "Hit Chance"
            case .incItemRarity: return "Item Rarity"
            case .incItemQuantity: return "Item Quantity"
            }
        }

        func valueRange(for level: Int) -> ClosedRange<Double> {
            let level = Double(level)
            switch self {
            case .armour: return 10*level...12*level
            case .percentArmour: return 0.01...0.1
            case .flatMaxLife: return 5*level...7*level
            case .percentMaxLife: return 0.01...0.1
            case .flatMaxMana: return 5*level...7*level
            case .percentMaxMana: return 0.01...0.1
            case .lifeRegen: return 0.5*level...1*level
            case .fireRes: return 1...max(20, level/2)
            case .coldRes: return 1...max(20, level/2)
            case .lightningRes: return 1...max(20, level/2)
            case .strength: return 1*level...1.5*level
            case .dexterity: return 1*level...1.5*level
            case .intelligence: return 1*level...7*level
            case .percentPhysical: return 0.01...1.5
            case .flatPhysical: return 1*level...1.2*level
            case .flatCold: return 1*level...1.2*level
            case .flatFire: return 1*level...1.2*level
            case .flatLightning: return 1*level...1.2*level
            case .percentHitChance: return 0.01*level...0.05*level
            case .incItemRarity: return 1...40
            case .incItemQuantity: return 1...40
            }
        }
    }

    static let baseDefensiveStats = Defensive.baseStats
    static let baseOffensiveStats = Offensive.baseStats
    static let baseMiscStats = Misc.baseStats

    enum Defensive: Equatable, Codable {
        /// Base stats assume level 1 initially
        static var baseStats: [Stat.Defensive] = [
            .armour(10),
            .percentArmour(0),
            .flatMaxLife(80),
            .percentMaxLife(0),
            .flatMaxMana(80),
            .percentMaxMana(0),
            .lifeRegen(0.1),
            .fireRes(0),
            .coldRes(0),
            .lightningRes(0),
        ]

        case armour(Double)
        case percentArmour(Double)
        case flatMaxLife(Double)
        case percentMaxLife(Double)
        case flatMaxMana(Double)
        case percentMaxMana(Double)
        case lifeRegen(Double)
        case fireRes(Double)
        case coldRes(Double)
        case lightningRes(Double)

        var key: Key {
            switch self {
            case .armour: return .armour
            case .percentArmour: return .percentArmour
            case .flatMaxLife: return .flatMaxLife
            case .percentMaxLife: return .percentMaxLife
            case .flatMaxMana: return .flatMaxMana
            case .percentMaxMana: return .percentMaxMana
            case .lifeRegen: return .lifeRegen
            case .fireRes: return .fireRes
            case .coldRes: return .coldRes
            case .lightningRes: return .lightningRes
            }
        }
        var value: Double {
            switch self {
            case let .armour(value): return value
            case let .percentArmour(value): return value
            case let .flatMaxLife(value): return value
            case let .percentMaxLife(value): return value
            case let .flatMaxMana(value): return value
            case let .percentMaxMana(value): return value
            case let .lifeRegen(value): return value
            case let .fireRes(value): return value
            case let .coldRes(value): return value
            case let .lightningRes(value): return value
            }
        }
    }

    enum Offensive: Equatable, Codable {
        /// Base stats assume level 1 initially
        static var baseStats: [Stat.Offensive] = [
            .strength(0),
            .dexterity(0),
            .intelligence(0),
            .percentPhysical(0),
            .flatPhysical(0),
            .flatCold(0),
            .flatFire(0),
            .flatLightning(0),
            .percentHitChance(0.78),
        ]

        case strength(Double)
        case dexterity(Double)
        case intelligence(Double)
        case percentPhysical(Double)
        case flatPhysical(Double)
        case flatCold(Double)
        case flatFire(Double)
        case flatLightning(Double)
        case percentHitChance(Double)

        var key: Key {
            switch self {
            case .strength: return .strength
            case .dexterity: return .dexterity
            case .intelligence: return .intelligence
            case .percentPhysical: return .percentPhysical
            case .flatPhysical: return .flatPhysical
            case .flatCold: return .flatCold
            case .flatFire: return .flatFire
            case .flatLightning: return .flatLightning
            case .percentHitChance: return .percentHitChance
            }
        }
        var value: Double {
            switch self {
            case let .strength(value): return value
            case let .dexterity(value): return value
            case let .intelligence(value): return value
            case let .percentPhysical(value): return value
            case let .flatPhysical(value): return value
            case let .flatCold(value): return value
            case let .flatFire(value): return value
            case let .flatLightning(value): return value
            case let .percentHitChance(value): return value
            }
        }
    }

    enum Misc: Equatable, Codable {
        /// Base stats assume level 1 initially
        static var baseStats: [Stat.Misc] = [
            .incItemRarity(0),
            .incItemQuantity(0),
        ]

        case incItemRarity(Double)
        case incItemQuantity(Double)

        var key: Key {
            switch self {
            case .incItemRarity: return .incItemRarity
            case .incItemQuantity: return .incItemQuantity
            }
        }
        var value: Double {
            switch self {
            case let .incItemRarity(value): return value
            case let .incItemQuantity(value): return value
            }
        }
    }

    case defensive(Defensive)
    case offensive(Offensive)
    case misc(Misc)

    var key: Key {
        switch self {
        case let .defensive(stat): return stat.key
        case let .offensive(stat): return stat.key
        case let .misc(stat): return stat.key
        }
    }
}
