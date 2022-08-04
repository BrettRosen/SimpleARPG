//
//  Encounter.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/12/22.
//

import Foundation
import SwiftUI

struct PastEncounterState: Equatable {
    let encounter: Encounter
    let playerDamageLog: [DamageLogEntry]
}

struct Encounter: Equatable {

    enum WinLossState {
        case win
        case loss
    }

    static func generate(
        level: Int,
        rarity: Encounter.Rarity,
        incRarity: Double
    ) -> Encounter {
        guard let monsterBase = (Monster.Base.allCases
            .filter { $0.levelRange ~= level }
            .randomElement())
        else { fatalError() }

        var inventory: [InventorySlot] = []
        let inventorySize = 28

        // Monsters should have a minimum amount of certain items, the remaining slots will be randomized...
        let foodSlotCount = Int.random(in: 5...10)
        let coinSlotCount = 1

        let coins = pow(Double(Int.random(in: 10...100) * level), 1.2)
        inventory.append(.init(item: .coins(Int(coins))))

        for _ in 0..<foodSlotCount {
            let food = Food.generate(level: level)
            inventory.append(.init(item: .food(food)))
        }

        let monster = Monster(
            icon: monsterBase.icon,
            name: monsterBase.name,
            level: level,
            stats: [:],
            inventory: inventory,
            equipment: [
                Equipment.generateEquipment(level: level, slot: .weapon, incRarity: incRarity),
            ]
        )

        return .init(monster: monster, rarity: rarity)
    }

    enum Rarity {
        case normal, magic, rare

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

    var winLossState: WinLossState?
    var rarity: Rarity = .normal
    var monster: Monster
    var mods: [Modifier] = []
    var itemRarity: Double = 0
    var itemQuantity: Double = 0

    var isOver: Bool { winLossState != nil }

    init(
        monster: Monster,
        rarity: Encounter.Rarity = .normal
    ) {
        self.monster = monster
        self.rarity = rarity

        generateEncounterProperties()
    }

    var tickCount: Int = 0
    var combatBeginTimerCount: Int = 3

    private mutating func generateEncounterProperties() {
        let modPool = Encounter.Modifier.allCases
        switch rarity {
        case .normal:
            mods = []
            itemRarity = 0
            itemQuantity = 0
        case .magic:
            let numMods = Int.random(in: 1...3)
            mods = Array(modPool.shuffled().prefix(numMods))
            itemRarity = mods.map(\.bonusModifiers.rarity).reduce(0, +)
            itemQuantity = mods.map(\.bonusModifiers.quantity).reduce(0, +)

            itemRarity += Double(numMods) * 0.04
            itemQuantity += Double(numMods) * 0.04
        case .rare:
            let numMods = Int.random(in: 3...6)
            mods = Array(modPool.shuffled().prefix(numMods))
            itemRarity = mods.map(\.bonusModifiers.rarity).reduce(0, +)
            itemQuantity = mods.map(\.bonusModifiers.quantity).reduce(0, +)

            itemRarity += Double(numMods) * 0.06
            itemQuantity += Double(numMods) * 0.06
        }
    }
}

extension Encounter {
    enum Modifier: CaseIterable, Identifiable {
        case cannotRegerateLife
        case incMonsterAttackSpeed
        case physReflect
        case addedFireDamage
        case addedColdDamage
        case addedLightningDamage

        var id: String { displayName }

        var bonusModifiers: (rarity: Double, quantity: Double) {
            switch self {
            case .cannotRegerateLife:
                return (rarity: 0.30, quantity: 0.50)
            case .incMonsterAttackSpeed:
                return (rarity: 0.10, quantity: 0.15)
            case .physReflect:
                return (rarity: 0.25, quantity: 0.45)
            case .addedFireDamage:
                return (rarity: 0.15, quantity: 0.20)
            case .addedColdDamage:
                return (rarity: 0.15, quantity: 0.20)
            case .addedLightningDamage:
                return (rarity: 0.15, quantity: 0.20)
            }
        }

        var displayName: String {
            switch self {
            case .cannotRegerateLife:
                return "Player cannot regenerate life"
            case .incMonsterAttackSpeed:
                return "Monster has increased attack speed"
            case .physReflect:
                return "Monster reflects physical damage"
            case .addedFireDamage:
                return "Monster has added fire damage"
            case .addedColdDamage:
                return "Monster has added cold damage"
            case .addedLightningDamage:
                return "Monster has added lightning damage"
            }
        }
    }
}
