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

    enum VendorType: Equatable, Codable {
        case items
        case encounters([Encounter])

        var name: String {
            switch self {
            case .items: return "Anya"
            case.encounters: return "Daryl"
            }
        }

        var title: String {
            switch self {
            case .items: return "Items"
            case.encounters: return "Encounters"
            }
        }

        var icon: String {
            switch self {
            case .items: return "👩🏼‍🌾"
            case .encounters: return "👨🏽‍🚒"
            }
        }

        var tabTypes: [TabType] {
            switch self {
            case .items: return [.weapons, .armor, .foodAndMisc]
            case let .encounters(encounters): return [.encounters(encounters)]
            }
        }
    }

    enum TabType: Equatable, Codable, TabIdentifiable, Hashable {
        case weapons
        case armor
        case foodAndMisc
        case encounters([Encounter])

        var name: String {
            switch self {
            case .weapons: return "Weapons"
            case .armor: return "Armor"
            case .foodAndMisc: return "Food & More"
            case .encounters: return "Encounters"
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

    var type: VendorType = .items
    var selectedTab: TabType = .weapons
    var tabs: [TabType: [InventorySlot]] = [:]
    var isActive: Bool = false

    init() { }

    /// Level is used to to determine the items that the vendor has for sale
    init(
        type: VendorType,
        level: Int = 1,
        player: Player
    ) {
        self.type = type

        for tabType in type.tabTypes {
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
            case let .encounters(encounters):
                tabs[tabType] = encounters
                    .filter { $0.monster.base != nil }
                    .map {
                        InventorySlot.init(item: .encounter(Encounter.generate(base: $0.monster.base!, level: $0.monster.level, rarity: .normal, player: player)))
                    }
            }
        }

        if let firstTab = type.tabTypes.first {
            selectedTab = firstTab
        }
    }
}
