//
//  OneHandedSword.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 9/21/22.
//

import Foundation

struct OneHandedSword: Equatable, Codable, WeaponBaseIdentifiable, EquipmentBaseIdentifiable {
    var special: SpecialAttack? = nil
    var damageType: DamageType = .melee
    var presentationDetails: EquipmentPresentationDetails = .init(xScale: -1, degreeRotation: 0, offSet: .init(width: 20, height: 0))
    var icon: String = "🗡"
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

    static let rustedSword: Self = .init(name: "Rusted Sword", levelRequirement: 1, damage: 4.0...10.0, critChance: 0.05)
    static let copperSword: Self = .init(name: "Copper Sword", levelRequirement: 5, strengthRequirement: 14, dexterityRequirement: 14, damage: 7.0...15.0, critChance: 0.05)
}
