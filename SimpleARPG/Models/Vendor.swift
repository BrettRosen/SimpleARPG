//
//  Vendor.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/4/22.
//

import Foundation

struct Vendor: Equatable {

    enum TabType: Equatable, TabIdentifiable {
        case weapons
        case armor
        case foodAndMisc

        var icon: String {
            switch self {
            case .weapons: return "⚔️"
            case .armor: return "🦺"
            case .foodAndMisc: return "🦐"
            }
        }
    }

    let name: String
    let icon: String

    /// Level is used to to determine the items that the vendor has for sale
    init(name: String = "Nathaniel", icon: String = "🥸", level: Int = 1) {
        self.name = name
        self.icon = icon

        var weapons = [InventorySlot]()
        for _ in 0..<10 {
            let weapon = Equipment.generateEquipment(level: level, slot: .weapon, incRarity: 0)
            weapons.append(.init(item: .equipment(weapon)))
        }
        tabs[.weapons] = weapons
    }

    var selectedTab: TabType = .weapons
    var tabs: [TabType: [InventorySlot]] = [
        .weapons: [], .armor: [], .foodAndMisc: []
    ]
}
