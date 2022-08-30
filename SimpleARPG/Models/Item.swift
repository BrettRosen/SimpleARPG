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

/// Defines items that can drop from mobs.
/// This is different than Item since we don't want the associted type
enum ItemDrop: Equatable {
    case food
    case equipment
    case encounter
    case coins
    case nothing
}

enum Item: Equatable, Codable {
    case food(Food)
    case equipment(Equipment)
    case encounter(Encounter)
    case coins(Int)

    /// At the moment, using this to determine if two items are the same "type"
    /// without comparing the associated values. An example is for stackable items
    var key: String {
        switch self {
        case .food: return "food"
        case .equipment: return "equipment"
        case .encounter: return "encounter"
        case .coins: return "coins"
        }
    }

    var stackable: Bool {
        switch self {
        case .food: return false
        case .equipment: return false
        case .encounter: return false
        case .coins: return true
        }
    }

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
        case let .encounter(encounter): return encounter.monster.icon.asset
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

    var price: Price? {
        switch self {
        case let .food(food): return food.price
        case let .equipment(equipment): return equipment.price
        case let .encounter(encounter): return encounter.price
        case .coins: return nil
        }
    }
}

struct Price: Equatable, Codable {
    var buy: Int
    var sell: Int
}

extension Item {
    static let shrimp: Item = .food(.shrimp)
}
