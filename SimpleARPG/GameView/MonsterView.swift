//
//  MonsterView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/27/22.
//

import ComposableArchitecture
import SwiftUI

struct MonsterView: View {
    let store: Store<GameState, GameAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            if let monster = viewStore.encounter?.monster {
                VStack(spacing: 5) {
                    Text(monster.name)
                        .font(.appFootnote)
                        .foregroundColor(.black)

                    ResourceBar(current: monster.currentLife, total: monster.maxLife, frontColor: .uiGreen, backColor: .uiRed, icon: "", showTotal: false, width: 80, height: 20)

                    ZStack {
                        Text(monster.icon)
                            .font(.system(size: 42))
                        Text("⛏").font(.system(size: 34))
                            .offset(x: monster.isAttacking ? -70 : -30)
                            .animation(.easeIn(duration: 0.2), value: monster.combatLockDetails.animation)

                        Text(verbatim: {
                            if case let .eating(food) = monster.combatLockDetails.animation { return food.icon }
                            return ""
                        }())
                        .font(.title)
                        .offset(y: monster.isEating ? 20 : 0)
                        .animation(.easeIn(duration: 0.1).repeatCount(6, autoreverses: true), value: monster.combatLockDetails.animation)
                    }
                }
                .transition(.move(edge: .trailing))
            } else {
                EmptyView()
            }
        }
    }
}
