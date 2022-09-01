//
//  SpecialAttack.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/31/22.
//

import Foundation

enum SpecialAttack: Equatable, Codable {
    case darkBow

    static let maxSpecialResource = 100
    static let ticksPerRestore = 6 / tickUnit // 30 sec / tickUnit.
    static let restoreAmount = 10

    var resourcePerUse: Int {
        switch self {
        case .darkBow: return 55
        }
    }

    var name: String {
        switch self {
        case .darkBow: return "🏹 Dark Bow"
        }
    }

    var description: String {
        switch self {
        case .darkBow: return "Fires 2 arrows, each dealing up to 50% more damage as fire damage"
        }
    }

    var keyframes: [KeyFrame] {
        switch self {
        case .darkBow:
            return [
                .init(timeInterval: 0, rotation: 0, scale: 1.0, offset: .zero, animationKind: .none),

                .init(timeInterval: 1, rotation: 0, scale: 1.2, offset: .init(width: -40, height: 0), animationKind: .easeIn),
                .init(timeInterval: 0.2, rotation: 0, scale: 1, offset: .init(width: 0, height: 0), animationKind: .easeOut),
            ]
        }
    }

    var animationTimeOffsets: [TimeInterval] {
        keyframes.map { $0.timeInterval }
    }
}
