//
//  EncounterPreview.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/21/22.
//

import SwiftUI

struct EncounterPreview: View {
    let encounter: Encounter

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 8) {
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
                .padding(.bottom, 8)

            HStack {
                Text("Modifiers")
                    .font(.appCaption).bold()
                    .foregroundColor(encounter.rarity.color)
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isExpanded ? 0 : -90))
            }

            if !encounter.mods.isEmpty {
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
        }
        .padding()
        .background(Rectangle().fill(Color.uiBackground))
        .cornerRadius(4)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
}

struct EncounterPreview_Previews: PreviewProvider {
    static var previews: some View {
        EncounterPreview(encounter: .init(monster: .init(icon: "👹", name: "Gobbo", level: 1, stats: [:])))
    }
}