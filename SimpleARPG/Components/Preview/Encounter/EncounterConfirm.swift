//
//  EncounterPreview.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/15/22.
//

import ComposableArchitecture
import SwiftUI

struct EncounterConfirm: View {
    let store: Store<GameState, GameAction>
    let encounter: Encounter

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 8) {
                Text("Encountering...")
                    .font(.appFootnote)
                    .foregroundColor(.white.opacity(0.75))

                Divider().frame(width: 80, height: 2)
                    .background(Color.white.opacity(0.2))

                VStack(spacing: 0) {
                    Text(encounter.monster.name.capitalized)
                        .font(.appCallout)
                        .foregroundColor(encounter.rarity.color)
                        .padding(.bottom, 8)
                    Text("Level \(encounter.monster.level)")
                        .font(.appCaption)
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                }

                Text(encounter.monster.icon)
                    .padding(12)
                    .background(encounter.rarity.color.gradient.shadow(.inner(color: .black.opacity(1), radius: 2, x: 0, y: 2)), in: Circle())

                Divider().frame(width: 80, height: 2)
                    .background(Color.white.opacity(0.2))

                Text("⚠️ Combat will begin shortly after confirming")
                    .font(.appCaption)
                    .foregroundColor(.white.opacity(0.75))

                HStack {
                    Button(action: {
                        viewStore.send(.closePreview, animation: .default)
                    }) {
                        Text("Cancel")
                            .frame(width: 80, height: 40)
                            .background(Color.uiRed, in: RoundedRectangle(cornerRadius: 2))

                    }
                    Button(action: {
                        viewStore.send(.beginEncounter(encounter), animation: .default)
                    }) {
                        Text("Fight")
                            .frame(width: 80, height: 40)
                            .background(Color.uiButton, in: RoundedRectangle(cornerRadius: 2))
                    }
                }
                .foregroundColor(.white)
                .font(.appCallout)
            }
            .padding()
            .background(Rectangle().fill(Color.uiBackground))
            .cornerRadius(4)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
        }
    }
}

struct EncounterConfirm_Previews: PreviewProvider {
    static var previews: some View {
        EncounterConfirm(store: .init(initialState: .init(), reducer: gameReducer, environment: .live), encounter: .init(monster: .init(icon: "👹", name: "Test man", level: 1, stats: [:])))
    }
}
