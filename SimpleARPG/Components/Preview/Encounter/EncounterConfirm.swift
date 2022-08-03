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
                    .font(.appCallout)
                    .foregroundColor(.white)

                EncounterPreview(encounter: encounter, transparentBackground: true)

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
            .background(RoundedRectangle(cornerRadius: 4).fill(Color.uiBackground))
        }
    }
}
