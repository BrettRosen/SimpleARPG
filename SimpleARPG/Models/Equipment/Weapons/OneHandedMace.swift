//
//  OneHandedMace.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 9/21/22.
//

import Foundation

struct OneHandedMace: Equatable, Codable, WeaponBaseIdentifiable, EquipmentBaseIdentifiable {
    var special: SpecialAttack? = nil
    var damageType: DamageType = .melee
    var presentationDetails: EquipmentPresentationDetails = .init(xScale: -1, degreeRotation: 0, offSet: .init(width: 20, height: 0))
    var icon: String = "🔨"
    var name: String = ""
    var slot: EquipmentSlot = .weapon
    var handidness: Handidness = .oneHand
    var levelRequirement: Int = 0
    var strengthRequirement: Double = 0
    var dexterityRequirement: Double = 0
    var intelligenceRequirement: Double = 0
    var damage: ClosedRange<Double> = 0.0...0.0
    var ticksPerAttack: Int = 3
    var critChance: Double = 0
    var affixPool: AffixPool = .init(
        prefix: [.percentPhysical, .flatPhysical, .flatCold, .flatFire, .flatLightning],
        suffix: [.dexterity, .strength, .fireRes, .coldRes, .lightningRes, .percentHitChance]
    )

    var stats: [Stat.Key : Double] = [:]

    static let driftwoodClub: Self = .init(name: "Driftwood Club", levelRequirement: 1, damage: 6.0...8.0, critChance: 0.05)
    static let tribalClub: Self = .init(name: "Tribal Club", levelRequirement: 1, damage: 9.0...14.0, critChance: 0.05)
}
