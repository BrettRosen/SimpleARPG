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
        .weapon(.oneHandedAxe(.rustedHatchet)),
        .weapon(.oneHandedAxe(.stoneAxe)),
        .weapon(.bow(.crudeBow)),
    ]

    case weapon(WeaponBase)
    //case armor(ArmorBase)

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
        .bow(.crudeBow)
    ]

    case oneHandedAxe(OneHandedAxe)
    case bow(Bow)

    var identifiableWeaponBase: any WeaponBaseIdentifiable {
        switch self {
        case let .oneHandedAxe(axe): return axe
        case let .bow(bow): return bow
        }
    }
    var identifiableEquipmentBase: any EquipmentBaseIdentifiable {
        switch self {
        case let .oneHandedAxe(axe): return axe
        case let .bow(bow): return bow
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

        static func rarity(for incRarity: Double = 0) -> Self {
            var rareUpperBound: Double = 3 * (1 + incRarity)
            var magicUpperBound: Double = 20 * (1 + incRarity)
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
        return .init(
            base: base,
            rarity: Equipment.Rarity.rarity(for: incRarity),
            stats: [:]
        )
    }
}

enum EquipmentSlot {
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

func generateDropFor(
    encounter: Encounter,
    player: Player
) -> Item? {
    var drops = encounter.monster.lootTable.drops

    let incItemRarity = encounter.itemRarity + player.stats[.incItemRarity]!
    let incItemQuantity = encounter.itemQuantity + player.stats[.incItemQuantity]!

    for (index, _) in drops.enumerated() {
        drops[index].weight *= (1 + Int(incItemRarity))
    }

    let randomNumberMax = drops.map(\.weight).reduce(0, +)
    let randomNumber = Int.random(in: 1...randomNumberMax)
    var selectedDrop: ItemDrop!

    for drop in drops {
        if randomNumber <= drop.weight {
            selectedDrop = drop.item
        }
    }

    switch selectedDrop {
    case .equipment:
        guard let base = EquipmentBase.allBases.filter({ $0.levelRequirement <= player.level }).shuffled().first else {
            fatalError()
        }
        return .equipment(.init(base: base, rarity: .normal, stats: [:]))
    case .food:
        return .food(Food.generate(level: player.level))
    case .encounter:
        return .encounter(Encounter.generate(
            level: player.level,
            rarity: Encounter.Rarity.rarity(for: incItemRarity),
            incRarity: incItemRarity
        ))
    case .nothing:
        return nil
    case .none:
        return nil
    }
}




