//
//  InventorySlot.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import Foundation

struct InventorySlot: Equatable, Identifiable {
    var id = UUID().uuidString
    var item: Item?
}
