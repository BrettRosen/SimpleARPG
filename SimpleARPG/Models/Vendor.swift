//
//  Vendor.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/4/22.
//

import Foundation

struct Vendor: Equatable, Codable, Identifiable, Hashable {
    typealias ID = String
    var id: ID = UUID().uuidString

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    enum TabType: Equatable, Codable, TabIdentifiable, Hashable {
        case weapons
        case armor
        case foodAndMisc
        case encounters([Encounter], Player)

        var name: String {
            switch self {
            case .weapons: return "Weapons"
            case .armor: return "Armor"
            case .foodAndMisc: return "Food & More"
            case .encounters: return "Encounter"
            }
        }

        var icon: String {
            switch self {
            case .weapons: return "⚔️"
            case .armor: return "🦺"
            case .foodAndMisc: return "🦐"
            case .encounters: return "🐺"
            }
        }

        /// Pretty much need hashable conformance for Vendor.tabs, but we never expect to have two tabs
        /// with the same icon
        func hash(into hasher: inout Hasher) {
            hasher.combine(icon)
        }
    }

    let name: String
    let icon: String

    var selectedTab: TabType = .weapons
    var tabs: [TabType: [InventorySlot]] = [:]
    var isActive: Bool = false

    /// Level is used to to determine the items that the vendor has for sale
    init(
        name: String = "Nathaniel",
        icon: String = "🥸",
        level: Int = 1,
        tabTypes: [TabType] = []
    ) {
        self.name = name
        self.icon = icon

        for tabType in tabTypes {
            switch tabType {
            case .weapons:
                tabs[tabType] = (0..<10).map { _ in
                    InventorySlot.init(item: .equipment(Equipment.generateEquipment(level: level, slot: .weapon, incRarity: 0)))
                }
            case .armor:
                tabs[tabType] = (0..<10).map { _ in
                    InventorySlot.init(item: .equipment(Equipment.generateEquipment(level: level, slot: EquipmentSlot.armorSlots.randomElement()!, incRarity: 0)))
                }
            case .foodAndMisc:
                tabs[tabType] = (0..<10).map { _ in
                    InventorySlot.init(item: .food(Food.generate(level: level)))
                }
            case let .encounters(encounters, player):
                tabs[tabType] = encounters
                    .filter { $0.monster.base != nil }
                    .map {
                        InventorySlot.init(item: .encounter(Encounter.generate(base: $0.monster.base!, level: $0.monster.level, rarity: .normal, player: player)))
                    }
            }
        }

        if let firstTab = tabTypes.first {
            selectedTab = firstTab
        }
    }
}
