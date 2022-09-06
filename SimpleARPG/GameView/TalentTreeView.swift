//
//  TalentTreeView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 9/5/22.
//

import SwiftUI

struct TalentTreeView: View {
    @State var tree = uniqueTalentTree

    var body: some View {
        ScrollView {
            Diagram(tree: tree) { value in
                Button(action: {

                }) {
                    Text("\(value.value.name)")
                        .foregroundColor(.white)
                        .font(.appCaption)
                        .padding(6)
                        .background(Color.uiButton, in: RoundedRectangle(cornerRadius: 4))
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                }
            }
        }
        .padding(16)
    }
}
