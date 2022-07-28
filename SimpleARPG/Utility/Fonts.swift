//
//  Fonts.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/11/22.
//

import Foundation
import SwiftUI

let fontName = "cryos-font"

extension Font {
    static let appSubheadline = Font.custom(fontName, size: 14)
    static let appBody = Font.custom(fontName, size: 12)
    static let appCallout = Font.custom(fontName, size: 10)
    static let appFootnote = Font.custom(fontName, size: 8)
    static let appCaption = Font.custom(fontName, size: 7)
}
