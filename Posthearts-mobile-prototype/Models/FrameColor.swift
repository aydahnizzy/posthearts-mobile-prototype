import SwiftUI

struct FrameColor: Identifiable, Equatable {
    let id = UUID()
    let h: Double
    let s: Double
    let l: Double
    var color: Color { Color(h: h, s: s, l: l) }

    static let all: [FrameColor] = [
        .init(h: 0,   s: 0,   l: 15),
        .init(h: 241, s: 80,  l: 64),
        .init(h: 320, s: 100, l: 84),
        .init(h: 20,  s: 89,  l: 54),
        .init(h: 47,  s: 99,  l: 62),
        .init(h: 30,  s: 100, l: 29),
        .init(h: 0,   s: 0,   l: 83),
        .init(h: 155, s: 41,  l: 42),
        .init(h: 207, s: 93,  l: 50),
        .init(h: 350, s: 85,  l: 40),
        .init(h: 324, s: 97,  l: 65),
        .init(h: 209, s: 92,  l: 69),
        .init(h: 289, s: 87,  l: 63),
        .init(h: 0,   s: 5,   l: 61),
    ]
}
