//
//  Extensions+View.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/6/22.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
