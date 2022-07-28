//
//  TabView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import ComposableArchitecture
import Foundation
import SwiftUI

enum Tab {
    case stats
    case inventory
    case equipment
    case spells
    case settings

    var icon: String {
        switch self {
        case .stats: return "📊"
        case .inventory: return "🎒"
        case .equipment: return "⚔️"
        case .spells: return "📖"
        case .settings: return "⚙️"
        }
    }
}

struct TabView: View {
    let tab: Tab
    let selectedTab: Tab
    let namespace: Namespace.ID
    var statusText: String = ""
    var onTap: () -> ()

    var body: some View {
        ZStack(alignment: .bottom) {
            Text(tab.icon)
                .font(.title2)
                .frame(width: 50, height: 40)
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
        .onTapGesture { onTap() }
    }
}
