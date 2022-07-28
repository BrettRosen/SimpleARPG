//
//  Food.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import Foundation

struct Food: Equatable, InventoryDisplayable {
    var name: String
    var icon: String
    var restoreAmount: Double

    static let shrimp: Self = .init(name: "Shrimp", icon: "🦐", restoreAmount: 4)
    static let shark: Self = .init(name: "Shark", icon: "🦈", restoreAmount: 16)
}
