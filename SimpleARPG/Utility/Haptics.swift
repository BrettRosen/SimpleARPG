//
//  Haptics.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/19/22.
//

import Foundation
import UIKit

class Haptics {
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
