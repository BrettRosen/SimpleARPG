//
//  MessageView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/5/22.
//

import ComposableArchitecture
import SwiftUI

extension GameState {
    var messageState: MessageState {
        get {
            .init(player: player, encounter: encounter)
        } set {
            player = newValue.player
            encounter = newValue.encounter
        }
    }
}

struct MessageState: Equatable {
    var player = Player()
    var encounter: Encounter?
}

enum MessageAction: Equatable {
    case tappedMessage(Message)
    case clear(Message, CombatPlayer)
}

struct MessageEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let messageReducer: Reducer<MessageState, MessageAction, MessageEnvironment> = .init { state, action, env in
    enum MessageCancelId { }

    switch action {
    case let .tappedMessage(m):
        message(player: &state.player, message: m)

        return Effect(value: .clear(m, .player))
            .delay(for: .init(floatLiteral: tickUnit * 4), scheduler: env.mainQueue)
            .eraseToEffect()
            .cancellable(id: MessageCancelId.self, cancelInFlight: true)
    case let .clear(message, player):
        switch player {
        case .player:
            state.player.currentMessage = nil
        case .monster:
            state.encounter?.monster.currentMessage = nil
        }
    }
    return .none
}

struct MessageButton: View {
    let message: String
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack {
                Text("💬")
                    .font(.appFootnote)

                Text(message)
                    .font(.appCaption)
            }
            .foregroundColor(.black)
            .padding(8)
            .background(Color.white, in: Capsule())
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
        }
    }
}

struct MessageView: View {
    let store: Store<MessageState, MessageAction>
    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack {
                    ForEach(Message.allCases, id: \.self) { message in
                        MessageButton(message: message.value) {
                            viewStore.send(.tappedMessage(message))
                        }
                    }
                }
                .padding(8)
            }
        }
    }
}
