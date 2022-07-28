//
//  Damage.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/18/22.
//

import Foundation

struct Damage {
    enum DamageType {
        case physical, fire, cold, lightning
    }
    var type: DamageType
    var rawAmount: Double
}
