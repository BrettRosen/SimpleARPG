//
//  Item.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import Foundation
import SwiftUI

protocol InventoryDisplayable {
    var icon: String { get }
}

enum Item: Equatable {
    case food(Food)
    case equipment(Equipment)
    case encounter(Encounter)
    case coins(Int)

    var name: String {
        switch self {
        case let .food(food): return food.name
        case let .equipment(equipment): return equipment.name
        case let .encounter(encounter): return encounter.monster.name
        case .coins: return "Coins"
        }
    }

    var icon: String {
        switch self {
        case let .food(food): return food.icon
        case let .equipment(equipment): return equipment.icon
        case let .encounter(encounter): return encounter.monster.icon
        case .coins: return "🪙"
        }
    }

    var rarityColor: Color? {
        switch self {
        case .food, .coins: return nil
        case let .equipment(equipment): return equipment.rarity.color
        case let .encounter(encounter): return encounter.rarity.color
        }
    }
}

extension Item {
    static let shark: Item = .food(.shrimp)
    static let rustedHatchetMock: Item = .equipment(.init(base: .weapon(.oneHandedAxe(.rustedHatchet)), rarity: .rare, stats: [
        Stat.Key.strength: 10,
        Stat.Key.dexterity: 8
    ]))

    static let encounter: Item = .encounter(Encounter.generate(level: 5))
}
