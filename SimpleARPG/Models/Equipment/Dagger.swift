//
//  Dagger.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/18/22.
//

import Foundation

struct Dagger: Equatable, WeaponBaseIdentifiable, EquipmentBaseIdentifiable {
    var damageType: DamageType = .melee
    var presentationDetails: EquipmentPresentationDetails = .init()
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

    static let glassShank: Self = .init(presentationDetails: .init(xScale: -1, degreeRotation: -30, offSet: .init(width: 20, height: 0)), name: "Glass Shank", levelRequirement: 1, strengthRequirement: 9, dexterityRequirement: 6, damage: 6.0...10.0, critChance: 0.06)

    static let allBases = [
        OneHandedAxe.rustedHatchet,
    ]
}
