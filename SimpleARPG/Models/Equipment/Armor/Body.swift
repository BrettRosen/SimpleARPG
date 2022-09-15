//
//  Body.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 9/1/22.
//

import Foundation

struct Body: Equatable, Codable, EquipmentBaseIdentifiable {
    var presentationDetails: EquipmentPresentationDetails = .init()
    var icon: String = "🦺"
    var name: String = ""
    var slot: EquipmentSlot = .body
    var levelRequirement: Int = 1
    var strengthRequirement: Double = 0
    var dexterityRequirement: Double = 0
    var intelligenceRequirement: Double = 0
    var affixPool: AffixPool = .init(prefix: [
        .armour,
        .percentArmour,
        .flatMaxLife,
        .flatMaxMana,
        .percentArmour,
        .flatMaxLife
    ], suffix: [
        .lifeRegen,
        .strength,
        .dexterity,
        .intelligence
    ])

    var stats: [Stat.Key : Double] = [:]

    static let plateVest = Self(name: "Plate Vest", stats: [
        .armour: 19,
    ])
}
