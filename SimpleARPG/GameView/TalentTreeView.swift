//
//  TalentTreeView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 9/5/22.
//

import ComposableArchitecture
import SwiftUI

extension GameState {
    var talentTreeState: TalentTreeState {
        get {
            .init(local: talentTreeLocalState, player: player)
        } set {
            talentTreeLocalState = newValue.local
            player = newValue.player
        }
    }
}

struct TalentTreeLocalState: Equatable, Codable {
    var previewingTalent: TalentPoint?
}

struct TalentTreeState: Equatable, Codable {
    var local: TalentTreeLocalState = .init()
    var player = Player()
}

enum TalentTreeAction: Equatable {
    case tappedTalentPoint(TalentPoint)
    case closePreview
    case tappedUnlock(TalentPoint)
}

struct TalentTreeEnvironment {

}

let talentTreeReducer: Reducer<TalentTreeState, TalentTreeAction, TalentTreeEnvironment> = .init { state, action, env in
    switch action {
    case let .tappedTalentPoint(talent):
        state.local.previewingTalent = talent
    case .closePreview:
        state.local.previewingTalent = nil
    case let .tappedUnlock(talent):
        guard state.player.talentPoints > 0 else { return .none }
        state.player.talentTree.forEachLevelFirst { tree in
            if tree.value.value == talent {
                tree.value.value.claimed = true
                state.player.talentPoints -= 1
                tree.children.forEach { $0.value.value.unlocked = true }
                state.player.stats.merge(tree.value.value.stats, uniquingKeysWith: +)
            }
        }

    }
    return .none
}

struct TalentTreeView: View {
    let store: Store<TalentTreeState, TalentTreeAction>

    func color(from talent: TalentPoint) -> Color {
        if talent.claimed {
            return .uiGreen
        } else if talent.unlocked {
            return .uiButton
        } else {
            return .uiRed
        }
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                VStack {
                    HStack {
                        Text("Points: \(viewStore.player.talentPoints)")
                            .font(.appCallout)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    Spacer()
                }
                .padding([.top, .leading], 6)

                ScrollView {
                    Diagram(tree: viewStore.player.talentTree) { unique in
                        Button(action: {
                            viewStore.send(.tappedTalentPoint(unique.value))
                        }) {
                            Text("\(unique.value.name)")
                                .foregroundColor(.white)
                                .font(.appCaption)
                                .padding(6)
                                .background(color(from: unique.value), in: RoundedRectangle(cornerRadius: 4))
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                        }
                    }
                }
                .padding(16)

                if let previewingTalent = viewStore.local.previewingTalent {
                    ZStack {
                        Group {
                            Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    viewStore.send(.closePreview, animation: .default)
                                }
                                .transition(.opacity)

                            VStack(spacing: 8) {
                                Text(previewingTalent.name)
                                    .font(.appCallout)
                                    .foregroundColor(.white)
                                Text(previewingTalent.description)
                                    .font(.appCaption)
                                    .foregroundColor(.white)

                                Divider().frame(width: 100).overlay(Color.uiBorder)

                                if previewingTalent.unlocked && !previewingTalent.claimed {
                                    Button(action: {
                                        viewStore.send(.tappedUnlock(previewingTalent))
                                    }) {
                                        VStack(spacing: 4) {
                                            Text("Unlock")
                                                .font(.appCallout)
                                                .foregroundColor(.white)
                                            Text("1 Point")
                                                .font(.appCaption)
                                                .foregroundColor(.white)
                                        }
                                        .padding(8)
                                        .background(Color.uiGreen.opacity(viewStore.player.talentPoints > 0 ? 1 : 0.2), in: RoundedRectangle(cornerRadius: 2))
                                    }
                                }
                            }
                            .padding(12)
                            .frame(width: 250)
                            .background {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.uiBackground)
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                            }
                            .transition(.opacity)
                        }
                        .zIndex(5)
                    }
                }
            }
        }
    }
}
