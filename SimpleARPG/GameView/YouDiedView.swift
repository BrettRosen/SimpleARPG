//
//  YouDiedView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/27/22.
//

import SwiftUI

struct YouDiedView: View {
    let didTapRevive: () -> ()

    var body: some View {
        VStack(spacing: 8) {
            Text("YOU DIED")
                .foregroundColor(.white)
                .font(.appBody)
            Text("Your equipment has been destroyed in battle.")
                .foregroundColor(.white)
                .font(.appCaption)
                .opacity(0.6)
                .padding(.bottom, 8)

            Button(action: {
                didTapRevive()
            }) {
                Text("✨ Revive")
                    .font(.appFootnote)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.uiButton.gradient, in: RoundedRectangle(cornerRadius: 4))
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
            }

        }
        .padding()
        .frame(width: screen.width)
        .background(Color.uiRed.opacity(1), in: Rectangle())
        .transition(.slide)
    }
}
