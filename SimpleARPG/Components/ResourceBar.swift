//
//  ResourceBar.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/7/22.
//

import Foundation
import SwiftUI

struct ResourceBar: View {

    var current: Double
    var total: Double
    var frontColor: Color
    var backColor: Color = .uiBackground
    var icon: String
    var showTotal: Bool = true

    var width: CGFloat
    var height: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(backColor.gradient)
                .frame(width: width, height: height)
            Rectangle()
                .fill(frontColor.gradient)
                .frame(width: width * CGFloat(current/total), height: height)
                .animation(.default, value: current)

            HStack {
                Spacer()
                Image(systemName: icon).foregroundColor(frontColor).font(.footnote)
                Spacer()
            }

            HStack {
                Spacer()
                if showTotal {
                    Text("\(Int(current))/\(Int(total))").font(.appCaption).bold().foregroundColor(.white.opacity(0.75))
                        .padding(.trailing, 8)
                }
            }
        }
        .frame(width: width, height: height)
    }
}

struct ResourceBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ResourceBar(current: 50, total: 100, frontColor: .red, icon: "❤️", width: 200, height: 20)
            ResourceBar(current: 50, total: 100, frontColor: .red, icon: "❤️", width: 200, height: 20)
        }
    }
}
