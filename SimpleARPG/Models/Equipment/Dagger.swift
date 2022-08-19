//
//  Dagger.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/18/22.
//

import Foundation

struct Dagger: Equatable, WeaponBaseIdentifiable, EquipmentBaseIdentifiable {
    var damageType: DamageType = .melee
    var presentationDetails: EquipmentPresentationDetails = .init(xScale: -1, degreeRotation: -45, offSet: .init(width: 25, height: 0))
    var icon: String = "🗡"
    var name: String = ""
    var slot: EquipmentSlot = .weapon
    var handidness: Handidness = .oneHand
    var levelRequirement: Int = 0
    var strengthRequirement: Double = 0
    var dexterityRequirement: Double = 0
    var intelligenceRequirement: Double = 0
    var damage: ClosedRange<Double> = 0.0...0.0
    var ticksPerAttack: Int = 2
    var critChance: Double = 0
    var affixPool: AffixPool = .init(
        prefix: [.flatPhysical, .flatCold, .flatFire, .flatLightning],
        suffix: [.dexterity, .intelligence]
    )

    static let glassShank: Self = .init(name: "Glass Shank", levelRequirement: 1, dexterityRequirement: 9, intelligenceRequirement: 6, damage: 6.0...10.0, critChance: 0.06)
    static let skinningKnife: Self = .init(name: "Skinning Knife", levelRequirement: 5, dexterityRequirement: 16, intelligenceRequirement: 11, damage: 5.0...19.0, critChance: 0.06)
}
