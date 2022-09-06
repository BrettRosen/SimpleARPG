//
//  TreeDiagram.swift
//  SimpleARPG
//
//  Created by Brett Rosen on 7/20/22.
//

import Foundation
import SwiftUI

extension Tree: Equatable where A: Equatable { }
extension Tree: Hashable where A: Hashable { }

let uniqueTree: Tree<Unique<Int>> = binaryTree.map(Unique.init)
let binaryTree = Tree<Int>(50, children: [
    Tree(17, children: [
        Tree(12),
        Tree(23)
    ]),
    Tree(72, children: [
        Tree(54),
        Tree(72)
    ])
])

let uniqueTalentTree: Tree<Unique<TalentPoint>> = talentTree.map(Unique.init)
let talentTree = Tree<TalentPoint>(TalentPoint(name: "Max Life", stats: [.flatMaxLife: 5]),
    children: [
        Tree<TalentPoint>(TalentPoint(name: "Strength", stats: [.dexterity: 5]),
            children: [

            ]),
        Tree<TalentPoint>(TalentPoint(name: "Dexterity", stats: [.strength: 5]),
            children: [

            ]),
        Tree<TalentPoint>(TalentPoint(name: "Intelligence", stats: [.intelligence: 5]),
            children: [

            ])
    ]
)

struct StatusEffect {
    enum Ailment {
        case bleeding(amount: Double)
    }

    let ailment: Ailment
    let numberOfTicks: Int
    var currentNumberOfTicks: Int
}

struct TalentPoint: Identifiable {
    var id: String = UUID().uuidString

    let name: String
    let stats: [Stat.Key: Double]
}

//let strengthPoint: TalentPoint = TalentPoint(stats: [Stat.Key.strength: 10])
//
//let talentTree = Tree<TalentPoint>(strengthPoint, children: [
//
//])

struct Tree<A> {
    var value: A
    var children: [Tree<A>] = []
    init(_ value: A, children: [Tree<A>] = []) {
        self.value = value
        self.children = children
    }

    func map<B>(_ transform: (A) -> B) -> Tree<B> {
        Tree<B>(transform(value), children: children.map { $0.map(transform) })
    }
}

class Unique<A>: Identifiable {
    let value: A
    init(_ value: A) { self.value = value }
}

struct Line: Shape {
    var from: CGPoint
    var to: CGPoint
    var animatableData: AnimatablePair<CGPoint, CGPoint> {
        get { AnimatablePair(from, to) }
        set {
            from = newValue.first
            to = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: self.from)
            p.addLine(to: self.to)
        }
    }
}

struct CollectDict<Key: Hashable, Value>: PreferenceKey {
    static var defaultValue: [Key:Value] { [:] }
    static func reduce(value: inout [Key:Value], nextValue: () -> [Key:Value]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct Diagram<V: View>: View {
    let tree: Tree<Unique<TalentPoint>>
    let node: (Unique<TalentPoint>) -> V

    typealias Key = CollectDict<Unique.ID, Anchor<CGPoint>>

    var body: some View {
        VStack(alignment: .center) {
            node(tree.value)
               .anchorPreference(key: Key.self, value: .center, transform: {
                   [self.tree.value.id: $0]
               })
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(tree.children, id: \.value.id, content: { child in
                    Diagram(tree: child, node: self.node)
                })
            }
        }
        .backgroundPreferenceValue(Key.self, { (centers: [Unique.ID: Anchor<CGPoint>]) in
            GeometryReader { proxy in
                ForEach(self.tree.children, id: \.value.id, content: { child in
                    Line(
                        from: proxy[centers[self.tree.value.id]!],
                        to: proxy[centers[child.value.id]!]
                    ).stroke()
                })
            }
        })
    }
}

