//
//  Food.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import Foundation

enum Food: String, Codable, CaseIterable, InventoryDisplayable {
    case shrimp
    case chicken
    case sardine
    case bread
    case herring
    case mackerel
    case trout
    case cod
    case salmon
    case tuna
    case cake
    case lobster
    case bass
    case applePie
    case chocolateCake
    case pizza
    case monkfish
    case darkCrab
    case anglerfish

    var name: String {
        switch self {
        case .shrimp, .chicken, .sardine, .bread, .herring, .mackerel, .trout, .cod, .salmon, .tuna, .cake, .lobster, .bass, .monkfish, .anglerfish, .pizza:
            return rawValue.capitalized
        case .applePie: return "Apple Pie"
        case .chocolateCake: return "Chocolate Cake"
        case .darkCrab: return "Dark Crab"
        }
    }

    var icon: String {
        switch self {
        case .shrimp: return "🦐"
        case .chicken: return "🍗"
        case .sardine: return "🐟"
        case .bread: return "🥖"
        case .herring: return "🐟"
        case .mackerel: return "🐟"
        case .trout: return "🐟"
        case .cod: return "🐟"
        case .salmon: return "🐟"
        case .tuna: return "🐟"
        case .cake: return "🍰"
        case .lobster: return "🦞"
        case .bass: return "🐟"
        case .applePie: return "🥧"
        case .chocolateCake: return "🥮"
        case .pizza: return "🍕"
        case .monkfish: return "🐡"
        case .darkCrab: return "🦀"
        case .anglerfish: return "🎣"
        }
    }

    var restoreAmount: Double {
        switch self {
        case .shrimp: return 10
        case .chicken: return 100
        case .sardine: return 200
        case .bread: return 300
        case .herring: return 400
        case .mackerel: return 500
        case .trout: return 600
        case .cod: return 700
        case .salmon: return 800
        case .tuna: return 900
        case .cake: return 1000
        case .lobster: return 1100
        case .bass: return 1200
        case .applePie: return 1300
        case .chocolateCake: return 1400
        case .pizza: return 1500
        case .monkfish: return 1600
        case .darkCrab: return 1700
        case .anglerfish: return 1800
        }
    }

    var dropLevelRange: ClosedRange<Int> {
        switch self {
        case .shrimp: return 1...5
        case .chicken: return 4...10
        case .sardine: return 9...15
        case .bread: return 14...20
        case .herring: return 19...25
        case .mackerel: return 24...30
        case .trout: return 29...35
        case .cod: return 34...40
        case .salmon: return 39...45
        case .tuna: return 44...50
        case .cake: return 49...55
        case .lobster: return 54...60
        case .bass: return 59...65
        case .applePie: return 64...70
        case .chocolateCake: return 69...75
        case .pizza: return 74...80
        case .monkfish: return 79...85
        case .darkCrab: return 84...90
        case .anglerfish: return 89...100
        }
    }

    var price: Price {
        let minDropLevel = dropLevelRange.lowerBound
        return .init(buy: minDropLevel * 8, sell: minDropLevel * 6)
    }
}

extension Food {
    static func generate(level: Int) -> Food {
        guard let food = (Food.allCases
            .filter { $0.dropLevelRange ~= level }
            .randomElement())
        else { fatalError() }
        return food
    }
}
