//
//  SpecialAttack.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/30/22.
//

import ComposableArchitecture
import SwiftUI

extension GameState {
    var specialAttack: SpecialAttackState {
        get {
            SpecialAttackState(player: player, encounter: encounter)
        } set {
            player = newValue.player
            encounter = newValue.encounter
        }
    }
}

struct SpecialAttackState: Equatable {
    var player: Player = .init()
    var encounter: Encounter?
}

enum SpecialAttackAction: Equatable {
    case tappedSpecialAttack(SpecialAttack)
    case clearMessage
}

struct SpecialAttackEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

func darkBow<
    S: PlayerIdentifiable,
    S2: PlayerIdentifiable
>(
    damager: S,
    player: inout S2
) {
    let damage1 = damager.damagePerAttack.filter { !$0.secondary }.map(\.rawAmount).reduce(0, +)
    let damage2 = damager.damagePerAttack.filter { !$0.secondary }.map(\.rawAmount).reduce(0, +)

    let d1 = Damage(type: .magic(.fire), rawAmount: damage1 * 1.5)
    let d2 = Damage(type: .magic(.fire), rawAmount: damage2 * 1.5)

    damage(player: &player, damage: d1)
    damage(player: &player, damage: d2)
}

let specialAttackReducer: Reducer<SpecialAttackState, SpecialAttackAction, SpecialAttackEnvironment> = .init { state, action, env in
    enum MessageCancelId { }

    switch action {
    case let .tappedSpecialAttack(special):
        guard let encounter = state.encounter else {
            state.player.currentMessage = .error(.mustBeInCombat)
            return Effect(value: .clearMessage)
                .animation(.linear)
                .delay(for: .init(floatLiteral: tickUnit * 4), scheduler: env.mainQueue)
                .eraseToEffect()
                .cancellable(id: MessageCancelId.self, cancelInFlight: true)
        }
        // Must have the required resource and not already queued for a special attack...
        guard state.player.specialResource >= special.resourcePerUse,
            state.player.combatDetails.queuedSpecialAttack == nil else {
            return .none
        }

        state.player.combatDetails.queuedSpecialAttack = special

        return .none
    case .clearMessage:
        state.player.currentMessage = nil
    }
    return .none
}

struct SpecialAttackView: View {
    let store: Store<SpecialAttackState, SpecialAttackAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 12) {
                if let special = viewStore.player.weapon?.identifiableWeaponBase.special {
                    Text("\(special.name)")
                        .font(.appBody)
                        .foregroundColor(.purple)
                    
                    Text(special.description)
                        .foregroundColor(.white.opacity(0.6))
                        .font(.appFootnote)
                        .padding(.bottom, 32)
                        .frame(width: 250)

                    Button(action: {
                        viewStore.send(.tappedSpecialAttack(special))
                    }) {
                        ResourceBar(current: Double(viewStore.player.specialResource), total: Double(SpecialAttack.maxSpecialResource), frontColor: .green, icon: "🔋", width: 200, height: 25)
                            .overlay {
                                HStack {
                                    Text("Special Attack")
                                        .foregroundColor(.black.opacity(0.6))
                                        .font(.appCaption)
                                        .padding(.leading, 6)
                                    Spacer()
                                }
                            }
                            .padding(4)
                            .background {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(viewStore.player.combatDetails.queuedSpecialAttack != nil ? Color.yellow : Color.clear)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                            }

                    }
                } else {
                    Text("Your equipped weapon does not have a special attack")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.appFootnote)
                }
            }
        }
    }
}
