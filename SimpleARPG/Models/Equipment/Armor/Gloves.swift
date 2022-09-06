//
//  Gloves.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 9/1/22.
//

import Foundation

struct Gloves: Equatable, Codable, EquipmentBaseIdentifiable {
    var presentationDetails: EquipmentPresentationDetails = .init()
    var icon: String = "🧤"
    var name: String = ""
    var slot: EquipmentSlot = .gloves
    var levelRequirement: Int = 1
    var strengthRequirement: Double = 0
    var dexterityRequirement: Double = 0
    var intelligenceRequirement: Double = 0
    var affixPool: AffixPool = .init(prefix: [], suffix: [])

    var stats: [Stat.Key : Double] = [:]

    static let ironGauntlets = Self(name: "Iron Gauntlets", stats: [
        .armour: 6,
    ])
}
