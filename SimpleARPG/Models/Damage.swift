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

    var name: String {
        switch self {
        case .melee: return "Melee Physical Damage"
        case .ranged: return "Ranged Physical Damage"
        case let .magic(elementalType):
            switch elementalType {
            case .fire: return "Fire Damage"
            case .cold: return "Cold Damage"
            case .lightning: return "Lightning Damage"
            }
        }
    }
}

struct Damage: Equatable {
    var type: DamageType
    var rawAmount: Double
}

struct DamageLogEntry: Equatable, Identifiable {
    let id: UUID = UUID()
    let damage: Damage
    /// Controls the animation of the damage entry
    var show: Bool
}
