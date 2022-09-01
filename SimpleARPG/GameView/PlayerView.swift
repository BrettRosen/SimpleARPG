//
//  PlayerView.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/27/22.
//

import ComposableArchitecture
import SwiftUI

struct PlayerView: View {
    let store: Store<GameState, GameAction>
    let player: PlayerIdentifiable
    var xScale: CGFloat = 1

    @State private var idling = false

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: xScale == 1 ? .leading : .trailing) {
                VStack(alignment: xScale == 1 ? .leading : .trailing) {
                    if let message = player.currentMessage {
                        Text(message.value)
                            .foregroundColor(.black)
                            .font(.appCaption)
                            .transition(.scale(scale: 1.2))
                            .animation(.spring(response: 1, dampingFraction: 0.2), value: message)
                            .padding(6)
                            .background(Color.white, in: Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }

                    ZStack {
                        ZStack(alignment: .bottom) {
                            Circle()
                                .frame(width: idling ? 20 : 30, height: 40)
                                .foregroundColor(.black.opacity(0.8))
                                .blur(radius: idling ? 5 : 20)
                                .rotation3DEffect(.degrees(80), axis: (x: 1, y: 0, z: 0))
                                .offset(y: 20)

                            Text(player.icon.asset).font(.system(size: 42))
                                .scaleEffect(x: player.icon.xScale)
                                .offset(y: idling ? 6 : 0)
                        }
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: true), value: idling)

                        if let weapon = player.weapon {

                            if let special = weapon.identifiableWeaponBase.special, player.combatDetails.isSpecialAttacking {
                                TimelineView(.cyclic(timeOffsets: special.animationTimeOffsets)) { timeline in
                                    KeyframeUpdatingView(
                                        date: timeline.date,
                                        keyframes: special.keyframes,
                                        view: AnyView(

                                        Text(weapon.identifiableEquipmentBase.icon).font(.system(size: 34))
                                            .scaleEffect(x: weapon.identifiableEquipmentBase.presentationDetails.xScale)
                                            .rotationEffect(.init(degrees: weapon.identifiableEquipmentBase.presentationDetails.degreeRotation))
                                            .offset(x: weapon.identifiableEquipmentBase.presentationDetails.offSet.width, y: weapon.identifiableEquipmentBase.presentationDetails.offSet.height)
                                            .offset(y: idling ? 6 : 0)
                                    ))
                                }
                            } else {
                                Text(weapon.identifiableEquipmentBase.icon).font(.system(size: 34))
                                    .scaleEffect(x: weapon.identifiableEquipmentBase.presentationDetails.xScale)
                                    .rotationEffect(.init(degrees: weapon.identifiableEquipmentBase.presentationDetails.degreeRotation))
                                    .offset(x: player.combatDetails.isAttacking ? 50 : weapon.identifiableEquipmentBase.presentationDetails.offSet.width, y: weapon.identifiableEquipmentBase.presentationDetails.offSet.height)
                                    .animation(.easeIn(duration: 0.2), value: player.combatDetails.animation)
                                    .offset(y: idling ? 6 : 0)
                                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: true), value: idling)
                            }
                        }

                        Text(verbatim: {
                            if case let .eating(food) = player.combatDetails.animation { return food.icon }
                            return ""
                        }())
                        .font(.title)
                        .offset(y: player.combatDetails.isEating ? 20 : 0)
                        .animation(.easeIn(duration: 0.1).repeatCount(6, autoreverses: true), value: player.combatDetails.animation)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                    .scaleEffect(x: xScale)
                    .onAppear {
                        idling = true
                    }
                }

                // Damage log
                ForEach(player.damageLog) { entry in
                    Text("\(entry.damage.type.icon) \(Int(entry.damage.rawAmount))")
                        .font(.appCaption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 6)
                        .background(entry.damage.type.color, in: RoundedRectangle(cornerRadius: 4))
                        .offset(x: entry.splatOffset.x, y: entry.splatOffset.y)
                        .offset(y: entry.show ? -25 : 0)
                        .scaleEffect(entry.show ? (entry.damage.secondary ? 0.8 : 1.2) : (entry.damage.secondary ? 0.5 : 1))
                        .transition(.move(edge: .top))
                        .animation(.spring(response: 0.6, dampingFraction: 0.4), value: entry.show)
                        .opacity(entry.show ? 1 : 0)
                        .onAppear {
                            viewStore.send(.showDamageLogEntry(entry))
                        }
                }
            }
        }
    }
}

struct KeyframeUpdatingView: View {
    /// Current keyframe number
    @State var idx: Int = 0

    /// Timeline update
    let date: Date

    let keyframes: [KeyFrame]

    let view: AnyView

    var body: some View {
        view
            .modifier(KeyframeModifier(keyframe: keyframes[idx]))
            .animation(keyframes[idx].animation, value: idx)
            .onChange(of: date) { _ in advanceKeyFrame() }
            .onAppear { advanceKeyFrame()}
    }

    func advanceKeyFrame() {
        // Advance to next keyframe
        idx = (idx + 1) % keyframes.count

        // Skip first frame for animation, which we
        // only used as the initial state.
        if idx == 0 { idx = 1 }
    }
}

struct CyclicTimelineSchedule: TimelineSchedule {
    let timeOffsets: [TimeInterval]

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> Entries {
        Entries(last: startDate, offsets: timeOffsets)
    }

    struct Entries: Sequence, IteratorProtocol {
        var last: Date
        let offsets: [TimeInterval]

        var idx: Int = -1

        mutating func next() -> Date? {
            idx = (idx + 1) % offsets.count

            last = last.addingTimeInterval(offsets[idx])

            return last
        }
    }
}

extension TimelineSchedule where Self == CyclicTimelineSchedule {
    static func cyclic(timeOffsets: [TimeInterval]) -> CyclicTimelineSchedule {
        .init(timeOffsets: timeOffsets)
    }
}
