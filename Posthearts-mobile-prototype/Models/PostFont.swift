import SwiftUI
import UIKit

struct PostFont: Identifiable, Equatable {
    let id: String           // canonical name from web
    let displayName: String
    let baseSize: CGFloat
    let baseLineHeight: CGFloat
    let letterSpacing: CGFloat
    /// Builds a SwiftUI Font at the given final point size.
    /// Used when a real custom font with `id` is not registered.
    let build: (CGFloat) -> Font

    static func == (lhs: PostFont, rhs: PostFont) -> Bool { lhs.id == rhs.id }

    func swiftUIFont(scale: CGFloat = 1) -> Font {
        let size = baseSize * scale
        if UIFont(name: id, size: size) != nil {
            return .custom(id, size: size)
        }
        return build(size)
    }

    static let all: [PostFont] = [
        .init(id: "DM Mono",           displayName: "DM Mono",           baseSize: 13.9, baseLineHeight: 20.85, letterSpacing: 0.17,
              build: { .system(size: $0, design: .monospaced) }),
        .init(id: "Damion",            displayName: "Damion",            baseSize: 20,   baseLineHeight: 28,    letterSpacing: 1,
              build: { .system(size: $0, weight: .regular, design: .serif).italic() }),
        .init(id: "Finger Paint",      displayName: "Finger Paint",      baseSize: 14,   baseLineHeight: 28,    letterSpacing: 0,
              build: { .system(size: $0, weight: .heavy, design: .rounded) }),
        .init(id: "Geist",             displayName: "Geist",             baseSize: 14,   baseLineHeight: 24,    letterSpacing: 0,
              build: { .system(size: $0, weight: .regular, design: .default) }),
        .init(id: "Gloria Hallelujah", displayName: "Gloria Hallelujah", baseSize: 16,   baseLineHeight: 28,    letterSpacing: 1,
              build: { .custom("SnellRoundhand", size: $0) }),
        .init(id: "Inria Serif",       displayName: "Inria Serif",       baseSize: 15,   baseLineHeight: 24,    letterSpacing: 0,
              build: { .system(size: $0, weight: .regular, design: .serif) }),
        .init(id: "Instrument Serif",  displayName: "Instrument Serif",  baseSize: 16,   baseLineHeight: 24,    letterSpacing: 0.17,
              build: { .system(size: $0, weight: .regular, design: .serif) }),
        .init(id: "Mansalva",          displayName: "Mansalva",          baseSize: 18,   baseLineHeight: 28,    letterSpacing: 0,
              build: { .custom("MarkerFelt-Thin", size: $0) }),
        .init(id: "Marck Script",      displayName: "Marck Script",      baseSize: 20,   baseLineHeight: 28,    letterSpacing: 0,
              build: { .custom("SnellRoundhand-Bold", size: $0) }),
        .init(id: "Marhey",            displayName: "Marhey",            baseSize: 16,   baseLineHeight: 26,    letterSpacing: 0,
              build: { .system(size: $0, weight: .regular, design: .rounded) }),
        .init(id: "Martian Mono",      displayName: "Martian Mono",      baseSize: 12,   baseLineHeight: 24,    letterSpacing: 0,
              build: { .system(size: $0, design: .monospaced) }),
        .init(id: "Schoolbell",        displayName: "Schoolbell",        baseSize: 15,   baseLineHeight: 24,    letterSpacing: 0,
              build: { .custom("Noteworthy-Light", size: $0) }),
    ]

    static let byId: [String: PostFont] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
}
