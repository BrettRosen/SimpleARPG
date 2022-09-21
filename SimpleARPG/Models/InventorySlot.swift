//
//  InventorySlot.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import Foundation

struct InventorySlot: Equatable, Codable, Identifiable {
    var id = UUID().uuidString
    var item: Item?

    mutating func add(item: Item) {
        guard let originalItem = self.item else {
            self.item = item
            return
        }

        // Make sure the item is stackable and the same type
        guard item.stackable, originalItem.key == item.key else { return }

        switch originalItem {
        case let .coins(coins1):
            guard case let .coins(coins2) = item else {
                return
            }
            self.item = .coins(coins1 + coins2)
        default:
            return
        }
    }
}
