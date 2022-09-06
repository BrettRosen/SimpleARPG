//
//  Damage.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/18/22.
//

import Foundation
import SwiftUI

enum ElementalType: Equatable, Codable {
    case fire, cold, lightning
}

enum DamageType: Equatable, Codable {
    case melee
    case ranged
    case magic(ElementalType)

    var isPhysical: Bool {
        switch self {
        case .melee, .ranged: return true
        case .magic: return false
        }
    }

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

    var color: Color {
        switch self {
        case .melee: return .uiRed
        case .ranged: return .uiRed
        case let .magic(elementalType):
            switch elementalType {
            case .fire: return .orange
            case .cold: return .blue
            case .lightning: return .yellow
            }
        }
    }

    var icon: String {
        switch self {
        case .melee: return "🗡"
        case .ranged: return "🏹"
        case let .magic(elementalType):
            switch elementalType {
            case .fire: return "🔥"
            case .cold: return "❄️"
            case .lightning: return "⚡️"
            }
        }
    }
}

struct Damage: Equatable, Codable {
    var type: DamageType
    var rawAmount: Double
    /// This value is used to define damage that is not from the player's primary source
    var secondary: Bool = false
}

struct DamageLogEntry: Equatable, Codable, Identifiable {
    var id: UUID = UUID()
    let damage: Damage
    /// Controls the animation of the damage entry
    var show: Bool
    var splatOffset: CGPoint = CGPoint(x: .random(in: -30...30), y: .random(in: -30...30))
}
