//
//  Message.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/5/22.
//

import Foundation

enum Message: Equatable, Codable, CaseIterable, Hashable {
    static var allCases: [Message] = [
        .gg(.gg),
        .gg(.gf),
        .gg(.uDidWell),
        .gg(.sitTFDown),
        .bm(.zoggy)
    ]

    var value: String {
        switch self {
        case let .gg(message): return message.rawValue
        case let .bm(message): return message.rawValue
        case let .error(message): return message.rawValue
        }
    }

    case gg(GGMessage)
    case bm(BMMessage)
    case error(ErrorMessage)

    enum GGMessage: String, Codable, Equatable, CaseIterable {
        case gg = "gg"
        case gf = "gf"
        case uDidWell = "u did well but i did betta"
        case sitTFDown = "sit tf down brutha"
    }

    enum BMMessage: String, Codable, Equatable, CaseIterable {
        case zoggy = "zoggy"
    }

    enum ErrorMessage: String, Codable, Equatable, CaseIterable {
        case mustBeInCombat = "I must be in combat!"
    }
}
