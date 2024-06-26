//
//  Bow.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/2/22.
//

import Foundation

struct Bow: Equatable, Codable, WeaponBaseIdentifiable, EquipmentBaseIdentifiable {
    var special: SpecialAttack? = nil
    var damageType: DamageType = .ranged
    var presentationDetails: EquipmentPresentationDetails = .init(xScale: 1, degreeRotation: 15, offSet: .init(width: 20, height: 0))
    var icon: String = "🏹"
    var name: String = ""
    var slot: EquipmentSlot = .weapon
    var handidness: Handidness = .twoHand
    var levelRequirement: Int = 0
    var strengthRequirement: Double = 0
    var dexterityRequirement: Double = 0
    var intelligenceRequirement: Double = 0
    var damage: ClosedRange<Double> = 0.0...0.0
    var ticksPerAttack: Int = 2
    var critChance: Double = 0
    var affixPool: AffixPool = .init(
        prefix: [.percentPhysical, .flatPhysical, .flatCold, .flatFire, .flatLightning],
        suffix: [.dexterity, .fireRes, .coldRes, .lightningRes, .percentHitChance]
    )

    var stats: [Stat.Key : Double] = [:]

    static let crudeBow: Self = .init(special: .darkBow, name: "Crude Bow", levelRequirement: 1, damage: 5.0...13.0, critChance: 0.05)
}
