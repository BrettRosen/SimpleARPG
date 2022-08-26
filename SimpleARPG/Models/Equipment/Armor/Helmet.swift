//
//  Helmet.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/25/22.
//

import Foundation

struct Helmet: Equatable, Codable, EquipmentBaseIdentifiable {
    var presentationDetails: EquipmentPresentationDetails = .init()
    var icon: String = "🪖"
    var name: String = ""
    var slot: EquipmentSlot = .helmet
    var levelRequirement: Int = 1
    var strengthRequirement: Double = 0
    var dexterityRequirement: Double = 0
    var intelligenceRequirement: Double = 0
    var affixPool: AffixPool = .init(prefix: [], suffix: [])


}
