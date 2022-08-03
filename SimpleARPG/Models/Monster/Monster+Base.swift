//
//  Monster+Base.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/1/22.
//

import Foundation

extension Monster {
    enum Base: String, CaseIterable {
        case rat, spider, rabbit, chicken, duck

        /// An encounter with this monster can only be within this level range
        var levelRange: ClosedRange<Int> {
            switch self {
            case .rat: return 1...100
            case .spider: return 1...100
            case .rabbit: return 1...100
            case .chicken: return 1...100
            case .duck: return 1...100
            }
        }

        var name: String {
            switch self {
            case .rat, .spider, .rabbit, .chicken, .duck:
                return rawValue.capitalized
            }
        }

        var icon: String {
            switch self {
            case .rat: return "🐀"
            case .spider: return "🕷"
            case .rabbit: return "🐇"
            case .chicken: return "🐓"
            case .duck: return "🦆"
            }
        }
    }
}
