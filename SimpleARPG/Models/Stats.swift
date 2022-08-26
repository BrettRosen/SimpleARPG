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
        case flatMaxLife
        case percentMaxLife
        case strength
        case dexterity
        case intelligence
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
            case .flatMaxLife: return .int
            case .percentMaxLife: return .int
            case .strength: return .int
            case .dexterity: return .int
            case .intelligence: return .int
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
            case .flatMaxLife: return "Max Life"
            case .percentMaxLife: return "% Inc Life"
            case .strength: return "Strength"
            case .dexterity: return "Dexterity"
            case .intelligence: return "Intelligence"
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
            case .flatMaxLife: return 5*level...7*level
            case .percentMaxLife: return 5*level...7*level
            case .strength: return 1*level...1.5*level
            case .dexterity: return 1*level...1.5*level
            case .intelligence: return 1*level...7*level
            case .flatPhysical: return 1*level...1.2*level
            case .flatCold: return 1*level...1.2*level
            case .flatFire: return 1*level...1.2*level
            case .flatLightning: return 1*level...1.2*level
            case .percentHitChance: return 0.1*level...0.5*level
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
            .flatMaxLife(70),
            .percentMaxLife(0)
        ]

        case armour(Double)
        case flatMaxLife(Double)
        case percentMaxLife(Double)

        var key: Key {
            switch self {
            case .armour: return .armour
            case .flatMaxLife: return .flatMaxLife
            case .percentMaxLife: return .percentMaxLife
            }
        }
        var value: Double {
            switch self {
            case let .armour(value): return value
            case let .flatMaxLife(value): return value
            case let .percentMaxLife(value): return value
            }
        }
    }

    enum Offensive: Equatable, Codable {
        /// Base stats assume level 1 initially
        static var baseStats: [Stat.Offensive] = [
            .strength(20),
            .dexterity(20),
            .intelligence(20),
            .flatPhysical(0),
            .flatCold(0),
            .flatFire(0),
            .flatLightning(0),
            .percentHitChance(0.78),
        ]

        case strength(Double)
        case dexterity(Double)
        case intelligence(Double)
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
