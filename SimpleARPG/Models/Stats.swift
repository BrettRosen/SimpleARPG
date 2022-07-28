//
//  Stats.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/13/22.
//

import Foundation

enum Stat: Equatable, Codable {

    enum Key: String {
        case armour
        case flatMaxLife
        case percentMaxLife
        case strength
        case dexterity
        case intelligence
        case flatPhysical
        case incItemRarity
        case incItemQuantity
    }

    static let baseDefensiveStats = Defensive.baseStats
    static let baseOffensiveStats = Offensive.baseStats
    static let baseMiscStats = Misc.baseStats

    enum Defensive: Equatable, Codable {
        /// Base stats assume level 1 initially
        static var baseStats: [Stat.Defensive] = [
            .armour(10),
            .flatMaxLife(10),
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
        ]

        case strength(Double)
        case dexterity(Double)
        case intelligence(Double)
        case flatPhysical(Double)

        var key: Key {
            switch self {
            case .strength: return .strength
            case .dexterity: return .dexterity
            case .intelligence: return .intelligence
            case .flatPhysical: return .flatPhysical
            }
        }
        var value: Double {
            switch self {
            case let .strength(value): return value
            case let .dexterity(value): return value
            case let .intelligence(value): return value
            case let .flatPhysical(value): return value
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
