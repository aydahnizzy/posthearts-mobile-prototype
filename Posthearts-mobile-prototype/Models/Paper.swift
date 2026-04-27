import SwiftUI

struct Paper: Identifiable, Equatable {
    let id: String  // also the asset name (e.g., "brown")
    let displayName: String
    let padding: EdgeInsets       // in original 483.73-wide paper coordinates
    let cornerRadius: CGFloat
    let textColor: Color?         // nil = use default ink
    let isPro: Bool

    static func make(
        _ id: String,
        _ name: String,
        top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat,
        radius: CGFloat = 16,
        textColor: Color? = nil,
        pro: Bool = false
    ) -> Paper {
        Paper(
            id: id,
            displayName: name,
            padding: EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right),
            cornerRadius: radius,
            textColor: textColor,
            isPro: pro
        )
    }

    static let all: [Paper] = [
        .make("brown",       "Brown",       top: 39.81, bottom: 38.04, left: 32.42, right: 21.57),
        .make("pink",        "Pink",        top: 39.81, bottom: 38.04, left: 32.42, right: 21.57),
        .make("note-book",   "Notebook",    top: 47,    bottom: 66.5,  left: 55,    right: 21.73, pro: true),
        .make("a4-paper",    "A4",          top: 39.81, bottom: 38.04, left: 32.42, right: 21.57),
        .make("burnt-paper", "Burnt",       top: 39.81, bottom: 38.04, left: 32.42, right: 21.57, pro: true),
        .make("kisses",      "Kisses",      top: 29.05, bottom: 41.95, left: 22.85, right: 30.41,
              textColor: Color(h: 0, s: 100, l: 28), pro: true),
        .make("carton",      "Carton",      top: 39.98, bottom: 41.95, left: 27.87, right: 26.13,
              textColor: Color(h: 242, s: 70, l: 21)),
        .make("flowers",     "Flowers",     top: 38,    bottom: 72.85, left: 26.7,  right: 27.3,
              textColor: Color(h: 0, s: 35, l: 33), pro: true),
        .make("pink-stars",  "Pink Stars",  top: 30.98, bottom: 35.87, left: 27.96, right: 26.04,
              textColor: Color(h: 316, s: 94, l: 33)),
        .make("red-end",     "Red End",     top: 48.83, bottom: 88.02, left: 30,    right: 27.32,
              textColor: Color(h: 359, s: 89, l: 51), pro: true),
        .make("lovers",      "Lovers",      top: 37.98, bottom: 72.87, left: 27.7,  right: 26.3,
              textColor: Color(h: 331, s: 80, l: 29), pro: true),
        .make("old-flower",  "Old Flower",  top: 38.01, bottom: 98.84, left: 26.02, right: 27.98,
              textColor: Color(h: 0, s: 47, l: 24)),
    ]

    static let byId: [String: Paper] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
}

/// Original paper canvas dimensions (web reference).
enum PaperGeometry {
    static let designWidth: CGFloat = 483.73
    static let designHeight: CGFloat = 682.85
    static let aspect: CGFloat = designWidth / designHeight
}
