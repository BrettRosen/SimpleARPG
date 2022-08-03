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
    var handidness: Handidness { get }
    var damage: ClosedRange<Double> { get }
    var ticksPerAttack: Int { get }
    var critChance: Double { get }
}

enum EquipmentBase: Equatable {
    static var allBases: [EquipmentBase] = [
        .weapon(.oneHandedAxe(.rustedHatchet)),
        .weapon(.oneHandedAxe(.stoneAxe)),
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
        .oneHandedAxe(.init())
    ]

    case oneHandedAxe(OneHandedAxe)

    var identifiableWeaponBase: any WeaponBaseIdentifiable {
        switch self {
        case let .oneHandedAxe(axe): return axe
        }
    }
    var identifiableEquipmentBase: any EquipmentBaseIdentifiable {
        switch self {
        case let .oneHandedAxe(axe): return axe
        }
    }
}

struct OneHandedAxe: Equatable, WeaponBaseIdentifiable, EquipmentBaseIdentifiable {
    var presentationDetails: EquipmentPresentationDetails = .init()
    var icon: String = "🪓"
    var name: String = ""
    var slot: EquipmentSlot = .weapon
    var handidness: Handidness = .oneHand
    var levelRequirement: Int = 0
    var strengthRequirement: Double = 0
    var dexterityRequirement: Double = 0
    var intelligenceRequirement: Double = 0
    var damage: ClosedRange<Double> = 0.0...0.0
    var ticksPerAttack: Int = 4
    var critChance: Double = 0

    static let rustedHatchet: Self = .init(presentationDetails: .init(xScale: -1, degreeRotation: 0, offSet: .init(width: 20, height: 0)), name: "Rusted Hatchet", levelRequirement: 1, strengthRequirement: 12, dexterityRequirement: 6, damage: 6.0...11.0, critChance: 0.05)
    static let stoneAxe: Self = .init(presentationDetails: .init(xScale: -1, degreeRotation: 0, offSet: .init(width: 20, height: 0)), name: "Stone Axe", handidness: .twoHand, levelRequirement: 1, strengthRequirement: 17, dexterityRequirement: 8, damage: 12.0...20.0, ticksPerAttack: 5, critChance: 0.05)

    static let allBases = [
        OneHandedAxe.rustedHatchet,
    ]
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
    }

    var base: EquipmentBase
    var rarity: Rarity
    var stats: [Stat.Key: Double]

    var icon: String { base.icon }
    var name: String { base.name }
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

    let incItemRarity = 1 + encounter.itemRarity + player.stats[.incItemRarity]!
    let incItemQuantity = 1 + encounter.itemQuantity + player.stats[.incItemQuantity]!

    for (index, _) in drops.enumerated() {
        drops[index].weight *= Int(incItemRarity)
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
        return .encounter(Encounter.generate(level: player.level))
    case .nothing:
        return nil
    case .none:
        return nil
    }
}
