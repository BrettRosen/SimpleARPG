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

enum Tab: TabIdentifiable {
    case messages
    case stats
    case inventory
    case equipment
    case spells
    case settings

    var icon: String {
        switch self {
        case .messages: return "💬"
        case .stats: return "📊"
        case .inventory: return "🎒"
        case .equipment: return "⚔️"
        case .spells: return "📖"
        case .settings: return "⚙️"
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
                                .fill(Color.uiRed.gradient)
                                .matchedGeometryEffect(id: "Tab", in: namespace)
                                .shadow(color: .black, radius: 1, x: 0, y: 0)
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
