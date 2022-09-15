//
//  TabView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import ComposableArchitecture
import Foundation
import SwiftUI

protocol TabIdentifiable {
    var icon: String { get }
}

enum Tab: TabIdentifiable, Codable, Identifiable {
    var id: String { icon }

    case specialAttack
    case messages
    case stats
    case inventory
    case equipment
    case spells
    case settings

    /// This should be unique!
    var icon: String {
        switch self {
        case .specialAttack: return "🔋"
        case .messages: return "💬"
        case .stats: return "📊"
        case .inventory: return "🎒"
        case .equipment: return "⚔️"
        case .spells: return "📖"
        case .settings: return "⚙️"
        }
    }

    var statusText: ((ViewStore<GameState, GameAction>) -> String)? {
        switch self {
        case .specialAttack: return nil
        case .messages: return nil
        case .stats: return nil
        case .inventory: return nil
        case .equipment: return { viewStore in viewStore.player.weapon == nil ? "❗️Unarmed" : "" }
        case .spells: return nil
        case .settings: return  nil
        }
    }
}

struct TabView<T: TabIdentifiable & Equatable>: View {
    let tab: T
    let selectedTab: T
    let namespace: Namespace.ID
    var statusText: String = ""
    var onTap: () -> ()

    var body: some View {
        ZStack(alignment: .bottom) {
            Text(tab.icon)
                .font(.appSubheadline)
                .frame(width: 45, height: 35)
                .background {
                    ZStack {
                        if selectedTab != tab {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.uiButton.gradient)                            
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.uiRed.gradient.shadow(.inner(color: .black.opacity(0.4), radius: 2, x: 2, y: 2)))
                                .matchedGeometryEffect(id: "Tab", in: namespace)
                                //.shadow(color: .black, radius: 0, x: 0, y: 0)
                        }
                    }
                }

            Text(statusText).font(.appCaption)
                .foregroundColor(.white)
        }
        .animation(.spring(), value: selectedTab)
        .onTapGesture { onTap() }
    }
}
