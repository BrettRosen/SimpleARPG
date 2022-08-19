//
//  Equipment.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import Foundation
import SwiftUI

enum Handidness: Equatable {
    case oneHand
    case twoHand
}

struct EquipmentPresentationDetails: Equatable {
    var xScale: Double = 1
    var degreeRotation: Double = 0
    var offSet: CGSize = .zero
}

protocol EquipmentBaseIdentifiable: Equatable {
    var presentationDetails: EquipmentPresentationDetails { get }
    var icon: String { get }
    var name: String { get }
    var slot: EquipmentSlot { get }
    var levelRequirement: Int { get }
    var strengthRequirement: Double { get }
    var dexterityRequirement: Double { get }
    var intelligenceRequirement: Double { get }
    var affixPool: AffixPool { get }
}

protocol WeaponBaseIdentifiable: Equatable {
    var damageType: DamageType { get }
    var handidness: Handidness { get }
    var damage: ClosedRange<Double> { get }
    var ticksPerAttack: Int { get }
    var critChance: Double { get }
}

enum EquipmentBase: Equatable {
    static var allBases: [EquipmentBase] = [
        // One Handed Axe
        .weapon(.oneHandedAxe(.rustedHatchet)),
        .weapon(.oneHandedAxe(.stoneAxe)),
        // Bow
        .weapon(.bow(.crudeBow)),
        // Dagger
        .weapon(.dagger(.glassShank)),
        .weapon(.dagger(.skinningKnife))
    ]

    case weapon(WeaponBase)
    //case armor(ArmorBase)

    var affixPool: AffixPool {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.affixPool
        }
    }
    var icon: String {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.icon
        }
    }
    var name: String {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.name
        }
    }
    var levelRequirement: Int {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.levelRequirement
        }
    }
    var strengthRequirement: Double {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.strengthRequirement
        }
    }
    var dexterityRequirement: Double {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.dexterityRequirement
        }
    }
    var intelligenceRequirement: Double {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.intelligenceRequirement
        }
    }
    var slot: EquipmentSlot {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.slot
        }
    }
}

enum WeaponBase: Equatable {
    static let all: [WeaponBase] = [
        .oneHandedAxe(.rustedHatchet),
        .oneHandedAxe(.stoneAxe),
        .bow(.crudeBow),
        .dagger(.glassShank),
        .dagger(.skinningKnife),
    ]

    case oneHandedAxe(OneHandedAxe)
    case bow(Bow)
    case dagger(Dagger)

    var identifiableWeaponBase: any WeaponBaseIdentifiable {
        switch self {
        case let .oneHandedAxe(axe): return axe
        case let .bow(bow): return bow
        case let .dagger(dagger): return dagger
        }
    }
    var identifiableEquipmentBase: any EquipmentBaseIdentifiable {
        switch self {
        case let .oneHandedAxe(axe): return axe
        case let .bow(bow): return bow
        case let .dagger(dagger): return dagger
        }
    }
}

struct Equipment: Equatable, InventoryDisplayable {
    enum Rarity: Equatable {
        case normal
        case magic
        case rare

        var color: Color {
            switch self {
            case .normal: return .white
            case .magic: return .blue
            case .rare: return .yellow
            }
        }

        var priceModifier: Double {
            switch self {
            case .normal: return 1
            case .magic: return 2.2
            case .rare: return 3.4
            }
        }

        var maxAffixCount: Int {
            switch self {
            case .normal: return 0
            case .magic: return 2
            case .rare: return 3
            }
        }

        static func rarity(for incRarity: Double = 0) -> Self {
            let rareUpperBound: Double = 3 * (1 + incRarity)
            let magicUpperBound: Double = 20 * (1 + incRarity)
            let randomNumber = Double(Int.random(in: 1...100))
            switch randomNumber {
            case 1.0...rareUpperBound:
                return .rare
            case (rareUpperBound + 1.0)...magicUpperBound:
                return .magic
            default:
                return .normal
            }
        }
    }

    var base: EquipmentBase
    var rarity: Rarity
    var stats: [Stat.Key: Double]

    var icon: String { base.icon }
    var name: String { base.name }

    var price: Price {
        var price: Double = Double(base.levelRequirement) * 22.0 * rarity.priceModifier
        switch base {
        case .weapon: price *= 1.1
        }
        return .init(buy: Int(price), sell: Int(price * 0.75))
    }

    static func generateEquipment(
        level: Int,
        slot: EquipmentSlot,
        incRarity: Double
    ) -> Equipment {
        guard let base = EquipmentBase.allBases
            .filter({ $0.levelRequirement <= level && $0.slot == slot })
            .shuffled().first else {
            fatalError()
        }
        var affixPool = base.affixPool
        let rarity = Equipment.Rarity.rarity(for: incRarity)
        var stats: [Stat.Key: Double] = [:]
        let prefixCount = rarity == .normal ? 0 : Int.random(in: 1...rarity.maxAffixCount)
        let suffixCount = rarity == .normal ? 0 : Int.random(in: 1...rarity.maxAffixCount)

        // Given a random number of prefixes, grab a random one, assign a value, and remove it from the affix pool
        for _ in 0..<prefixCount {
            if let statKey = affixPool.prefix.randomElement() {
                stats[statKey] = Double.random(in: statKey.valueRange(for: level))
                affixPool.prefix.removeAll(where: { $0 == statKey })
            }
        }
        for _ in 0..<suffixCount {
            if let statKey = affixPool.suffix.randomElement() {
                stats[statKey] = Double.random(in: statKey.valueRange(for: level))
                affixPool.suffix.removeAll(where: { $0 == statKey })
            }
        }

        return .init(base: base, rarity: rarity, stats: stats)
    }
}

enum EquipmentSlot: CaseIterable {
    case helmet
    case body
    case weapon
    case ring
    case gloves
    case boots
    case offhand
    case amulet
    case belt

    var icon: String {
        switch self {
        case .helmet: return "🪖"
        case .body: return "👕"
        case .weapon: return "🗡"
        case .ring: return "💍"
        case .gloves: return "🧤"
        case .boots: return "🥾"
        case .offhand: return "🛡"
        case .amulet: return "🎖"
        case .belt: return "🩹"
        }
    }
}

func generateItem(
    level: Int,
    lootTable: LootTable,
    itemRarity: Double,
    player: Player
) -> Item? {
    var drops = lootTable.drops

    for (index, _) in drops.enumerated() {
        drops[index].weight *= (1 + Int(itemRarity))
    }

    let randomNumberMax = drops.map(\.weight).reduce(0, +)
    let randomNumber = Int.random(in: 1...randomNumberMax)
    var selectedDrop: ItemDrop!

    var previous = 0
    for drop in drops.sorted(by: { $0.weight < $1.weight }) {
        let range = (previous + 1)...(previous + drop.weight)
        if range ~= randomNumber {
            selectedDrop = drop.item
            break
        }
        previous += drop.weight
    }

    switch selectedDrop {
    case .equipment:
        let equipment = Equipment.generateEquipment(level: level, slot: .weapon, incRarity: player.stats[.incItemRarity]!)
        return .equipment(equipment)
    case .food:
        return .food(Food.generate(level: level))
    case .encounter:
        return .encounter(Encounter.generate(
            level: level,
            rarity: Encounter.Rarity.rarity(for: itemRarity),
            player: player
        ))
    case .coins:
        let coins = pow(Double(Int.random(in: 1...10) * level), 1.2)
        return .coins(Int(coins))
    case .nothing:
        return nil
    case .none:
        return nil
    }
}




