//
//  Monster+Base.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/1/22.
//

import Foundation

extension Monster {
    enum Base: String, CaseIterable {
        case rat, chicken, spider, rabbit, duck
        case ram

        case imp, goblin

        /// An encounter with this monster can only be within this level range
        var level: Int {
            switch self {
            case .rat: return 1
            case .spider: return 1
            case .rabbit: return 1
            case .chicken: return 1
            case .duck: return 1
            case .ram: return 1

            case .imp: return 2
            case .goblin: return 2
            }
        }

        var name: String {
            switch self {
            case .rat, .spider, .rabbit, .chicken, .duck, .ram, .goblin, .imp:
                return rawValue.capitalized
            }
        }

        var icon: PlayerIcon {
            switch self {
            case .rat: return .init(asset: "🐀", xScale: -1)
            case .spider: return .init(asset: "🕷", xScale: -1)
            case .rabbit: return .init(asset: "🐇", xScale: -1)
            case .chicken: return .init(asset: "🐓", xScale: -1)
            case .duck: return .init(asset: "🦆", xScale: -1)
            case .ram: return .init(asset: "🐏", xScale: -1)
            case .imp: return .init(asset: "👺", xScale: 1)
            case .goblin: return .init(asset: "👹", xScale: 1)
            }
        }
    }
}
