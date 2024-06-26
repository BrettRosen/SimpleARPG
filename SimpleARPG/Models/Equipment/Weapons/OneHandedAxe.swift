//
//  OneHandedAxe.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/2/22.
//

import Foundation

struct OneHandedAxe: Equatable, Codable, WeaponBaseIdentifiable, EquipmentBaseIdentifiable {
    var special: SpecialAttack? = nil
    var damageType: DamageType = .melee
    var presentationDetails: EquipmentPresentationDetails = .init(xScale: -1, degreeRotation: 0, offSet: .init(width: 20, height: 0))
    var icon: String = "🪓"
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

    static let rustedHatchet: Self = .init(name: "Rusted Hatchet", levelRequirement: 1, damage: 6.0...11.0, critChance: 0.05)
    static let stoneAxe: Self = .init(name: "Stone Axe", handidness: .twoHand, levelRequirement: 1, damage: 12.0...20.0, ticksPerAttack: 5, critChance: 0.05)
}
