//
//  PlayerView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/27/22.
//

import ComposableArchitecture
import SwiftUI

struct PlayerView: View {
    let store: Store<GameState, GameAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Text(viewStore.player.icon).font(.system(size: 42))

                if let weapon = viewStore.player.weapon {
                    Text(weapon.identifiableEquipmentBase.icon).font(.system(size: 34))
                        .scaleEffect(x: weapon.identifiableEquipmentBase.presentationDetails.xScale)
                        .rotationEffect(.init(degrees: weapon.identifiableEquipmentBase.presentationDetails.degreeRotation))
                        .offset(x: viewStore.player.isAttacking ? 50 : weapon.identifiableEquipmentBase.presentationDetails.offSet.width, y: weapon.identifiableEquipmentBase.presentationDetails.offSet.height)
                        .animation(.easeIn(duration: 0.2), value: viewStore.player.combatLockDetails.animation)
                }


                Text(verbatim: {
                    if case let .eating(food) = viewStore.player.combatLockDetails.animation { return food.icon }
                    return ""
                }())
                .font(.title)
                .offset(y: viewStore.player.isEating ? 20 : 0)
                .animation(.easeIn(duration: 0.1).repeatCount(6, autoreverses: true), value: viewStore.player.combatLockDetails.animation)
            }
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
        }
    }
}

