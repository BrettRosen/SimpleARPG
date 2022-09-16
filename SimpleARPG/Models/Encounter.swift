//
//  Encounter.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/12/22.
//

import Foundation
import SwiftUI

struct PastEncounterState: Equatable, Codable {
    let encounter: Encounter
    let playerDamageLog: [DamageLogEntry]
}

struct Encounter: Equatable, Codable {

    enum WinLossState: Codable {
        case win
        case loss
    }

    /// The incRarity and incQuantity here should generally come from the Player's stats.
    /// These will be added to the rarity and quantity generated from the Encounter's mods.
    static func generate(
        level: Int,
        rarity: Encounter.Rarity,
        player: Player
    ) -> Encounter {
        // Select a random monster base
        guard let monsterBase = (Monster.Base.allCases
            .filter { (max(1, level-5)...level+5) ~= $0.level }
            .randomElement())
        else { fatalError() }

        // Generate the modpool
        let modPool = Encounter.Modifier.allCases
        var mods: [Modifier] = []
        var encounterItemRarity: Double = 0
        var encounterItemQuantity: Double = 0

        switch rarity {
        case .normal:
            mods = []
            encounterItemRarity = 0
            encounterItemQuantity = 0
        case .magic:
            let numMods = Int.random(in: 1...3)
            mods = Array(modPool.shuffled().prefix(numMods))
            encounterItemRarity = mods.map(\.bonusModifiers.rarity).reduce(0, +)
            encounterItemQuantity = mods.map(\.bonusModifiers.quantity).reduce(0, +)

            encounterItemRarity += Double(numMods) * 0.04
            encounterItemQuantity += Double(numMods) * 0.04
        case .rare:
            let numMods = Int.random(in: 3...6)
            mods = Array(modPool.shuffled().prefix(numMods))
            encounterItemRarity = mods.map(\.bonusModifiers.rarity).reduce(0, +)
            encounterItemQuantity = mods.map(\.bonusModifiers.quantity).reduce(0, +)

            encounterItemRarity += Double(numMods) * 0.06
            encounterItemQuantity += Double(numMods) * 0.06
        }

        let finalItemRarity = encounterItemRarity + player.stats[.incItemRarity]!
        let finalItemQuantity = encounterItemQuantity + player.stats[.incItemQuantity]!

        // Generate the required inventory items for the monster
        var inventory: [InventorySlot] = []

        let foodCount = Monster.maxFoodCountRange.randomElement()!
        for _ in 0..<foodCount {
            let food = Food.generate(level: level)
            inventory.append(.init(item: .food(food)))
        }

        if mods.contains(.risking) {
            let coins = pow(Double(Int.random(in: 10...100) * level), 1.2)
            inventory.append(.init(item: .coins(Int(coins))))
        }

        // From the remaining open slots, we can generate some number of random items that the monster will have
        let remainingSlotCount = Monster.maxInventorySlots - inventory.count
        let maxRandomInventoryItem: Int = Int(Double(Monster.maxRandomInventoryItem) * (1 + finalItemQuantity))
        let randomInventoryItemCount = min(Int.random(in: 0...maxRandomInventoryItem), remainingSlotCount)

        for _ in 0..<randomInventoryItemCount {
            if let item = generateItem(level: level, lootTable: LootTable.default, itemRarity: finalItemRarity, player: player) {
                inventory.append(.init(item: item))
            }
        }

        let monster = Monster(
            icon: monsterBase.icon,
            name: monsterBase.name,
            level: level,
            stats: [:],
            inventory: inventory,
            equipment: [
                Equipment.generateEquipment(level: level, slot: .weapon, incRarity: finalItemRarity),
            ]
        )

        return .init(
            monster: monster,
            rarity: rarity,
            mods: mods,
            itemRarity: encounterItemRarity,
            itemQuantity: encounterItemQuantity
        )
    }

    enum Rarity: Codable {
        case normal, magic, rare

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

    var winLossState: WinLossState?
    var rarity: Rarity = .normal
    var monster: Monster
    var mods: [Modifier] = []
    var itemRarity: Double = 0
    var itemQuantity: Double = 0

    var isOver: Bool { winLossState != nil }

    var price: Price {
        let price: Double = Double(monster.level) * 20.0 * rarity.priceModifier
        return .init(buy: Int(price), sell: Int(price * 0.75))
    }

    init(
        monster: Monster,
        rarity: Encounter.Rarity = .normal,
        mods: [Modifier],
        itemRarity: Double,
        itemQuantity: Double
    ) {
        self.monster = monster
        self.rarity = rarity
        self.mods = mods
    }

    var tickCount: Int = 0
    var combatBeginTimerCount: Int = 3
}

extension Encounter {
    enum Modifier: Codable, CaseIterable, Identifiable {
        /// An unusual amount of coins in the monster's inventory
        case risking

        var id: String { displayName }

        var bonusModifiers: (rarity: Double, quantity: Double) {
            switch self {
            case .risking:
                return (rarity: 0.1, quantity: 0.15)
            }
        }

        var displayName: String {
            switch self {
            case .risking:
                return "Monster is risking"
            }
        }
    }
}
