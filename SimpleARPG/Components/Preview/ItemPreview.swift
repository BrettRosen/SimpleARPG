//
//  ItemPreview.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct ItemPreview: View {
    var item: Item
    var body: some View {
        switch item {
        case let .food(food):
            EmptyView()
        case let .equipment(equipment):
            EquipmentPreview(equipment: equipment)
        case let .encounter(encounter):
            EncounterPreview(encounter: encounter)
        }
    }
}

struct ItemPreview_Previews: PreviewProvider {
    static var previews: some View {
        ItemPreview(item: .rustedHatchetMock)
    }
}
