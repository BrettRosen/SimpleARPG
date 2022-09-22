//
//  Equipment.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import Foundation
import SwiftUI

enum Handidness: Equatable, Codable {
    case oneHand
    case twoHand
}

struct EquipmentPresentationDetails: Equatable, Codable {
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
    var stats: [Stat.Key: Double] { get }
}

protocol WeaponBaseIdentifiable: Equatable {
    var special: SpecialAttack? { get set }
    var damageType: DamageType { get }
    var handidness: Handidness { get }
    var damage: ClosedRange<Double> { get }
    var ticksPerAttack: Int { get }
    var critChance: Double { get }
}

enum EquipmentBase: Equatable, Codable {
    static var allBases: [EquipmentBase] = [
        // MARK: Weapons

        // One Handed Axe
        .weapon(.oneHandedAxe(.rustedHatchet)),
        .weapon(.oneHandedAxe(.stoneAxe)),
        // Bow
        .weapon(.bow(.crudeBow)),
        // Dagger
        .weapon(.dagger(.glassShank)),
        .weapon(.dagger(.skinningKnife)),

        // MARK: Armor
        // Helmet
        .armor(.helmet(.ironHat)),
        // Body
        .armor(.body(.plateVest)),
        // Gloves
        .armor(.gloves(.ironGauntlets)),
        // Boots
        .armor(.boots(.ironGreaves)),
        // Belt
        .armor(.belt(.chainBelt)),
        // Offhand
        .armor(.offhand(.splinteredTowerShield)),
        // Ring
        .armor(.ring(.coralRing())),
        // Amulet
        .armor(.amulet(.pauaAmulet)),
    ]

    case weapon(WeaponBase)
    case armor(ArmorBase)

    var stats: [Stat.Key: Double] {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.stats
        case let .armor(armor): return armor.identifiableEquipmentBase.stats
        }
    }
    var affixPool: AffixPool {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.affixPool
        case let .armor(armor): return armor.identifiableEquipmentBase.affixPool
        }
    }
    var icon: String {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.icon
        case let .armor(armor): return armor.identifiableEquipmentBase.icon
        }
    }
    var name: String {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.name
        case let .armor(armor): return armor.identifiableEquipmentBase.name
        }
    }
    var levelRequirement: Int {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.levelRequirement
        case let .armor(armor): return armor.identifiableEquipmentBase.levelRequirement
        }
    }
    var strengthRequirement: Double {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.strengthRequirement
        case let .armor(armor): return armor.identifiableEquipmentBase.strengthRequirement
        }
    }
    var dexterityRequirement: Double {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.dexterityRequirement
        case let .armor(armor): return armor.identifiableEquipmentBase.dexterityRequirement
        }
    }
    var intelligenceRequirement: Double {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.intelligenceRequirement
        case let .armor(armor): return armor.identifiableEquipmentBase.intelligenceRequirement
        }
    }
    var slot: EquipmentSlot {
        switch self {
        case let .weapon(weapon): return weapon.identifiableEquipmentBase.slot
        case let .armor(armor): return armor.identifiableEquipmentBase.slot
        }
    }
}

enum ArmorBase: Equatable, Codable {
    case helmet(Helmet)
    case body(Body)
    case gloves(Gloves)
    case boots(Boots)
    case belt(Belt)
    case offhand(Offhand)
    case ring(Ring)
    case amulet(Amulet)

    var identifiableEquipmentBase: any EquipmentBaseIdentifiable {
        switch self {
        case let .helmet(helmet): return helmet
        case let .body(body): return body
        case let .gloves(gloves): return gloves
        case let .boots(boots): return boots
        case let .belt(belt): return belt
        case let .offhand(offhand): return offhand
        case let .ring(ring): return ring
        case let .amulet(amulet): return amulet
        }
    }
}

enum WeaponBase: Equatable, Codable {

    static let all: [WeaponBase] = [
        .oneHandedAxe(.rustedHatchet),
        .oneHandedAxe(.stoneAxe),
        .oneHandedSword(.rustedSword),
        .oneHandedSword(.copperSword),
        .oneHandedMace(.driftwoodClub),
        .oneHandedMace(.tribalClub),
        .bow(.crudeBow),
        .dagger(.glassShank),
        .dagger(.skinningKnife),
    ]

    case oneHandedAxe(OneHandedAxe)
    case oneHandedSword(OneHandedSword)
    case oneHandedMace(OneHandedMace)
    case bow(Bow)
    case dagger(Dagger)

    /// This is currently the only concise way I could think of to update some property on `identifiableWeaponBase`
    /// being that is a get-only property, we instead have to make a new copy of it, change the value and reconstruct
    /// a WeaponBase with the newly updated weapon base
    func updateWeaponIdentifiableBase<KeyPathType>(path: PartialKeyPath<any WeaponBaseIdentifiable>, to value: KeyPathType) -> Self {
        guard let writableKeyPath = path as? WritableKeyPath<any WeaponBaseIdentifiable, KeyPathType> else {
            fatalError("Invalid value \(value) for keypath")
        }
        var copy = identifiableWeaponBase
        copy[keyPath: writableKeyPath] = value
        switch self {
        case .oneHandedAxe: return .oneHandedAxe(copy as! OneHandedAxe)
        case .oneHandedSword: return .oneHandedSword(copy as! OneHandedSword)
        case .oneHandedMace: return .oneHandedMace(copy as! OneHandedMace)
        case .bow: return .bow(copy as! Bow)
        case .dagger: return .dagger(copy as! Dagger)
        }
    }

    var identifiableWeaponBase: any WeaponBaseIdentifiable {
        switch self {
        case let .oneHandedAxe(axe): return axe
        case let .oneHandedSword(sword): return sword
        case let .oneHandedMace(mace): return mace
        case let .bow(bow): return bow
        case let .dagger(dagger): return dagger
        }
    }
    var identifiableEquipmentBase: any EquipmentBaseIdentifiable {
        switch self {
        case let .oneHandedAxe(axe): return axe
        case let .oneHandedSword(sword): return sword
        case let .oneHandedMace(mace): return mace
        case let .bow(bow): return bow
        case let .dagger(dagger): return dagger
        }
    }
}

struct Equipment: Equatable, Codable, InventoryDisplayable {
    enum Rarity: Equatable, Codable {
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
    var nonBaseStats: [Stat.Key: Double]

    init(base: EquipmentBase, rarity: Rarity, nonBaseStats: [Stat.Key: Double]) {
        self.base = base
        self.rarity = rarity
        self.nonBaseStats = nonBaseStats
    }

    var stats: [Stat.Key: Double] {
        nonBaseStats.merging(base.stats, uniquingKeysWith: { $0 + $1 })
    }

    var icon: String { base.icon }
    var name: String { base.name }

    var price: Price {
        var price: Double = Double(base.levelRequirement) * 22.0 * rarity.priceModifier
        switch base {
        case .weapon: price *= 1.2
        case .armor: price *= 1.1
        }
        return .init(buy: Int(price), sell: Int(price * 0.75))
    }

    static func generateWeapon(
        level: Int,
        incRarity: Double,
        forceSpecialAttack: Bool
    ) -> Equipment {
        let equipment = generateEquipment(level: level, slot: .weapon, incRarity: incRarity)
        if case let .weapon(weaponBase) = equipment.base, forceSpecialAttack {
            let newBase = weaponBase.updateWeaponIdentifiableBase(path: \.special, to: Optional<SpecialAttack>.some(.darkBow))
            return Equipment(base: .weapon(newBase), rarity: equipment.rarity, nonBaseStats: equipment.nonBaseStats)
        }
        return equipment
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

        return .init(base: base, rarity: rarity, nonBaseStats: stats)
    }
}

enum EquipmentSlot: CaseIterable, Codable {
    case helmet
    case body
    case weapon
    case ring
    case gloves
    case boots
    case offhand
    case amulet
    case belt

    static let armorSlots: [EquipmentSlot] = [
        .helmet,
        .body,
        .ring,
        .gloves,
        .boots,
        .offhand,
        .amulet,
        .belt,
    ]

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
        let equipment = Equipment.generateEquipment(level: level, slot: EquipmentSlot.allCases.randomElement()!, incRarity: player.stats[.incItemRarity]!)
        return .equipment(equipment)
    case .food:
        return .food(Food.generate(level: level))
    case .encounter:
        return .encounter(Encounter.generate(
            level: level + 2, // This is to account for being able to acquire harder content from mobs that are just your level
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




