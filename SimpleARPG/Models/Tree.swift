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
extension Tree: Codable where A: Codable { }

func generateTalentTree() -> Tree<Unique<TalentPoint>> {
    let talentTree = Tree<TalentPoint>(TalentPoint(name: "❤️", description: "+5 to Maximum Life", stats: [.flatMaxLife: 5], unlocked: true),
        children: [
            Tree<TalentPoint>(TalentPoint(name: "💪🏽", description: "+5 to Strength", stats: [.dexterity: 5]),
                children: [
                    Tree<TalentPoint>(TalentPoint(name: "💪🏽", description: "+5 to Strength", stats: [.dexterity: 5]),
                        children: [

                        ]),
                    Tree<TalentPoint>(TalentPoint(name: "🏃🏽", description: "+5 to Dexterity", stats: [.strength: 5]),
                        children: [

                        ]),
                    Tree<TalentPoint>(TalentPoint(name: "🧠", description: "+5 to Intelligence", stats: [.intelligence: 5]),
                        children: [

                        ])
                ]),
            Tree<TalentPoint>(TalentPoint(name: "🏃🏽", description: "+5 to Dexterity", stats: [.strength: 5]),
                children: [
                    Tree<TalentPoint>(TalentPoint(name: "💪🏽", description: "+5 to Strength", stats: [.dexterity: 5]),
                        children: [

                        ]),
                    Tree<TalentPoint>(TalentPoint(name: "🏃🏽", description: "+5 to Dexterity", stats: [.strength: 5]),
                        children: [

                        ]),
                    Tree<TalentPoint>(TalentPoint(name: "🧠", description: "+5 to Intelligence", stats: [.intelligence: 5]),
                        children: [

                        ])
                ]),
            Tree<TalentPoint>(TalentPoint(name: "🧠", description: "+5 to Intelligence", stats: [.intelligence: 5]),
                children: [
                    Tree<TalentPoint>(TalentPoint(name: "💪🏽", description: "+5 to Strength", stats: [.dexterity: 5]),
                        children: [

                        ]),
                    Tree<TalentPoint>(TalentPoint(name: "🏃🏽", description: "+5 to Dexterity", stats: [.strength: 5]),
                        children: [

                        ]),
                    Tree<TalentPoint>(TalentPoint(name: "🧠", description: "+5 to Intelligence", stats: [.intelligence: 5]),
                        children: [

                        ])
                ])
        ]
    )
    let uniqueTalentTree: Tree<Unique<TalentPoint>> = talentTree.map(Unique<TalentPoint>.init)
    return uniqueTalentTree
}


struct StatusEffect {
    enum Ailment {
        case bleeding(amount: Double)
    }

    let ailment: Ailment
    let numberOfTicks: Int
    var currentNumberOfTicks: Int
}

struct TalentPoint: Equatable, Identifiable, Codable {
    var id: String = UUID().uuidString

    let name: String
    let description: String
    let stats: [Stat.Key: Double]
    var unlocked: Bool = false
    var claimed: Bool = false
}

struct Queue<Element> {
    var elements: [Element] = []

    var isEmpty: Bool {
        return elements.isEmpty
    }

    @discardableResult
    mutating func enqueue(_ element: Element) -> Bool {
        elements.append(element)
        return true
    }

    mutating func dequeue() -> Element? {
        return isEmpty ? nil : elements.removeFirst()
    }
}


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

    mutating func forEachLevelFirst(_ visit: (inout Tree) -> Void) {
        visit(&self)
        var queue = Queue<Tree>()
        children.forEach {
            queue.enqueue($0)
        }
        while var node = queue.dequeue() {
            visit(&node)
            node.children.forEach {
                queue.enqueue($0)
            }
        }
    }
}

class Unique<A: Codable & Equatable>: Identifiable, Codable, Equatable {
    static func == (lhs: Unique<A>, rhs: Unique<A>) -> Bool {
        lhs.value == rhs.value
    }

    var value: A
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

