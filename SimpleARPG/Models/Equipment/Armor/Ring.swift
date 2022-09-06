//
//  Ring.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 9/1/22.
//

import Foundation

struct Ring: Equatable, Codable, EquipmentBaseIdentifiable {
    var presentationDetails: EquipmentPresentationDetails = .init()
    var icon: String = "💍"
    var name: String = ""
    var slot: EquipmentSlot = .ring
    var levelRequirement: Int = 1
    var strengthRequirement: Double = 0
    var dexterityRequirement: Double = 0
    var intelligenceRequirement: Double = 0
    var affixPool: AffixPool = .init(prefix: [
        .flatPhysical,
        .flatCold,
        .flatFire,
        .flatLightning,
        .flatMaxLife,
        .flatMaxMana,
        .incItemRarity
    ], suffix: [
        .lifeRegen,
        .incItemRarity,
        .dexterity,
        .strength,
        .intelligence,
    ])

    var stats: [Stat.Key : Double] = [:]

    static func coralRing() -> Self {
        Self(name: "Coral Ring", stats: [
            .flatMaxLife : .random(in: 20...30)
        ])
    }
}
