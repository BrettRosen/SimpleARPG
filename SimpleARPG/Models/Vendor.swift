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

    var name: String = ""
    var icon: String = ""

    var selectedTab: TabType = .weapons
    var tabs: [TabType: [InventorySlot]] = [
        .weapons: [], .armor: [], .foodAndMisc: []
    ]
}
