//
//  YouDiedView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/27/22.
//

import SwiftUI

struct YouDiedView: View {
    let didTapRevive: () -> ()
    let playerDamageLog: [DamageLogEntry]
    let monsterDamageLog: [DamageLogEntry]

    var body: some View {
        VStack(spacing: 8) {
            Text("YOU DIED!")
                .foregroundColor(.white)
                .font(.appCallout)

            Button(action: {
                didTapRevive()
            }) {
                Text("✨ Revive")
                    .font(.appFootnote)
                    .foregroundColor(.white)
                    .frame(width: 100)
                    .padding(12)
                    .background(Color.uiButton.gradient, in: RoundedRectangle(cornerRadius: 2))
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
            }
            .padding(.bottom, 8)

            Divider()
                .frame(height: 1)
                .overlay(Color.white.opacity(0.2))
                .padding(.bottom, 8)

            Text("Enemy Damage:")
                .font(.appFootnote)
                .foregroundColor(.white)

            ScrollView(showsIndicators: true) {
                VStack(spacing: 8) {
                    ForEach(playerDamageLog) { entry in
                        Text("Monster hit you for ").font(.appFootnote).foregroundColor(.white.opacity(0.7)) +
                        Text("\(Int(entry.damage.rawAmount)) ").font(.appFootnote).foregroundColor(.white) +
                        Text("\(entry.damage.type.name)")
                            .font(.appCaption)
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(height: 50)
        }
        .padding()
        .frame(width: screen.width)
        .background(Color.uiRed, in: Rectangle())
        .transition(.slide)
    }
}
