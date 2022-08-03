//
//  YouWonView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/3/22.
//

import SwiftUI

struct YouWonView: View {
    let didTapExit: () -> ()

    var body: some View {
        VStack(spacing: 8) {
            Text("YOU WON")
                .foregroundColor(.white)
                .font(.appBody)
            Text("Tap to loot the enemy's inventory & equipment below!")
                .foregroundColor(.white)
                .font(.appCallout)
                .opacity(0.7)
                .padding(.bottom, 8)

            Button(action: {
                didTapExit()
            }) {
                Text("🚪 Exit")
                    .font(.appFootnote)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.uiGreen.gradient, in: RoundedRectangle(cornerRadius: 4))
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
            }

        }
        .padding()
        .frame(width: screen.width)
        .background(Color.uiGreen.opacity(1), in: Rectangle())
        .transition(.slide)
    }
}

struct YouWonView_Previews: PreviewProvider {
    static var previews: some View {
        YouWonView(didTapExit: {})
    }
}
