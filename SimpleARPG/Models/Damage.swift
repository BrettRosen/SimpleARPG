//
//  Damage.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/18/22.
//

import Foundation

enum ElementalType: Equatable {
    case fire, cold, lightning
}

enum DamageType: Equatable {
    case melee
    case ranged
    case magic(ElementalType)
}

struct Damage {
    var type: DamageType
    var rawAmount: Double
}
