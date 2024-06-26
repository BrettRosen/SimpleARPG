//
//  Monster+Base.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/1/22.
//

import Foundation

extension Monster {
    enum Base: String, CaseIterable, Codable {
        case rat, chicken, spider, rabbit, duck
        case ram

        case imp, goblin, man, woman

        case caveGoblin

        case boar

        /// An encounter with this monster can only be within this level range
        var level: Int {
            switch self {
            case .rat,
                .spider,
                .rabbit,
                .chicken,
                .duck,
                .ram:
                return 1
            case .imp,
                .goblin,
                .man,
                .woman:
                return 2
            case .caveGoblin:
                return 3
            case .boar:
                return 5
            }
        }

        var name: String {
            switch self {
            case .rat, .spider, .rabbit, .chicken, .duck, .ram, .goblin, .imp, .man, .woman, .boar:
                return rawValue.capitalized
            case .caveGoblin:
                return "Cave Goblin"
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
            case .man: return .init(asset: "👱🏼‍♂️", xScale: 1)
            case .woman: return .init(asset: "👩🏼‍🦳", xScale: 1)
            case .caveGoblin: return .init(asset: "👹", xScale: 1)
            case .boar: return .init(asset: "🐗", xScale: -1)
            }
        }
    }
}
