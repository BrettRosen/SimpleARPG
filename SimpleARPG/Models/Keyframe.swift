//
//  Keyframe.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 8/30/22.
//

import Foundation
import SwiftUI

enum KeyFrameAnimation {
    case none
    case linear
    case linearAutoReverse
    case easeOut
    case easeIn
}

struct KeyFrame {
    let timeInterval: TimeInterval
    let rotation: Double
    let scale: Double
    let offset: CGSize
    let animationKind: KeyFrameAnimation

    var animation: Animation? {
        switch animationKind {
        case .none: return nil
        case .linearAutoReverse: return .linear(duration: timeInterval).repeatCount(1, autoreverses: true)
        case .linear: return .linear(duration: timeInterval)
        case .easeIn: return .easeIn(duration: timeInterval)
        case .easeOut: return .easeOut(duration: timeInterval)
        }
    }
}

struct KeyframeModifier: ViewModifier {
    let keyframe: KeyFrame

    func body(content: Content) -> some View {
        content
            .scaleEffect(keyframe.scale)
            .rotationEffect(Angle(degrees: keyframe.rotation))
            .offset(x: keyframe.offset.width, y: keyframe.offset.height)
    }
}
