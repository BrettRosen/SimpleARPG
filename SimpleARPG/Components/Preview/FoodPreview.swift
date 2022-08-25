//
//  FoodPreview.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/25/22.
//

import Foundation
import SwiftUI

struct FoodPreview: View {
    let food: Food

    var body: some View {
        VStack {
            Text("Restores \(Int(food.restoreAmount)) health on use.")
                .font(.appFootnote)
                .foregroundColor(.white)
        }
    }
}
