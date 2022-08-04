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
    let player: PlayerIdentifiable
    var xScale: CGFloat = 1

    @State private var idling = false

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Group {
                    Text(player.icon.asset).font(.system(size: 42))
                        .scaleEffect(x: player.icon.xScale)

                    if let weapon = player.weapon {
                        Text(weapon.identifiableEquipmentBase.icon).font(.system(size: 34))
                            .scaleEffect(x: weapon.identifiableEquipmentBase.presentationDetails.xScale)
                            .rotationEffect(.init(degrees: weapon.identifiableEquipmentBase.presentationDetails.degreeRotation))
                            .offset(x: player.isAttacking ? 50 : weapon.identifiableEquipmentBase.presentationDetails.offSet.width, y: weapon.identifiableEquipmentBase.presentationDetails.offSet.height)
                            .animation(.easeIn(duration: 0.2), value: player.combatLockDetails.animation)
                    }

                    Text(verbatim: {
                        if case let .eating(food) = player.combatLockDetails.animation { return food.icon }
                        return ""
                    }())
                    .font(.title)
                    .offset(y: player.isEating ? 20 : 0)
                    .animation(.easeIn(duration: 0.1).repeatCount(6, autoreverses: true), value: player.combatLockDetails.animation)
                }
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                .scaleEffect(x: xScale)
                .offset(y: idling ? 6 : 0)
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: true), value: idling)
                .onAppear {
                    idling = true
                }

                // Damage log
                ForEach(player.damageLog) { entry in
                    Text("\(Int(entry.damage.rawAmount))")
                        .font(.appCaption)
                        .foregroundColor(.white)
                        .background {
                            Image(systemName: "seal.fill")
                                .frame(width: 15, height: 15)
                                .foregroundColor(entry.damage.rawAmount == 0 ? .blue : .uiRed)
                                .scaleEffect(entry.show ? 1.5 : 1)
                        }
                        .offset(y: entry.show ? -25 : 0)
                        .scaleEffect(entry.show ? 1.4 : 1)
                        .transition(.move(edge: .top))
                        .animation(.spring(response: 0.6, dampingFraction: 0.4), value: entry.show)
                        .opacity(entry.show ? 1 : 0)
                        .onAppear {
                            viewStore.send(.showDamageLogEntry(entry))
                        }
                }
            }
        }
    }
}

