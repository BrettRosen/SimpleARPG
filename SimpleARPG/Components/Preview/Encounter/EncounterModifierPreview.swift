//
//  EncounterModifierPreview.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/13/22.
//

import SwiftUI

struct EncounterModifierPreview: View {

    let encounter: Encounter

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("\(encounter.monster.icon.asset) " + encounter.monster.name)
                    .font(.appCallout).bold()
                    .foregroundColor(encounter.rarity.color)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isExpanded ? 0 : -90))
            }
            Text("Level \(encounter.monster.level)")
                .font(.appFootnote).bold()
                .foregroundColor(.white)
                .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 5) {
                ForEach(encounter.mods) { mod in
                    Text(mod.displayName)
                        .font(.appCaption)
                        .foregroundColor(.white)
                }
            }
            .opacity(0.75)
            .frame(height: isExpanded ? nil : 0, alignment: .top)
            .clipped()
        }
        .padding(8)
        .background(Color.uiBackground)
        .cornerRadius(2)
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
}
