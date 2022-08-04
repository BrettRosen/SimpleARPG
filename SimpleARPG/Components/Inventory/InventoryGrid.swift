//
//  InventoryGrid.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/29/22.
//

import SwiftUI

private let maxSlotWidth: CGFloat = 35
private let slotSpacing: CGFloat = 8

struct InventoryGrid: View {

    let inventory: [InventorySlot]
    let slotBackgroundColor: (InventorySlot) -> Color

    var contextMenu: ((InventorySlot) -> AnyView)? = nil
    var dropDelegate: ((InventorySlot) -> DropDelegate)? = nil
    var inventorySlotTapped: ((InventorySlot) -> Void)? = nil
    var onDrag: ((InventorySlot) -> Void)? = nil

    private let columns = Array(repeating: GridItem(.flexible(minimum: 10, maximum: maxSlotWidth), spacing: slotSpacing), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: slotSpacing) {
            ForEach(inventory) { slot in
                Button(action: {
                    inventorySlotTapped?(slot)
                }) {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(slot.item?.rarityColor?.opacity(0.6) ?? Color.uiBorder, lineWidth: 2)
                        .background(RoundedRectangle(cornerRadius: 4).fill(slotBackgroundColor(slot).shadow(ShadowStyle.inner(color: .black, radius: 2, x: 0, y: 0))))
                        .frame(minHeight: maxSlotWidth, maxHeight: .infinity)
                        .overlay {
                            ZStack(alignment: .bottomTrailing) {
                                Text(slot.item?.icon ?? "")
                                    .font(.title)
                                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)

                                if let item = slot.item, case let .coins(coins) = item {
                                    Text("\(coins)").font(.appCaption).foregroundColor(.white)
                                }
                            }
                        }
                }
                .onDrag {
                    onDrag?(slot)
                    return NSItemProvider(contentsOf: URL(string: "\(slot.id)")!)!
                } preview: {
                    if let item = slot.item {
                        VStack {
                            Text(item.name).font(.appFootnote).foregroundColor(.white)
                            Text(item.icon).font(.largeTitle)
                        }
                    }
                }
                .if(dropDelegate != nil) { view in
                    view.onDrop(of: [.url], delegate: dropDelegate!(slot))
                }
                .if(contextMenu != nil) { view in
                    view.contextMenu { contextMenu!(slot) }
                }
            }
        }
        .frame(maxWidth: 4 * maxSlotWidth + 3 * slotSpacing)
        .padding(8)
        .background(Color.uiDarkBackground.cornerRadius(2))
    }
}
