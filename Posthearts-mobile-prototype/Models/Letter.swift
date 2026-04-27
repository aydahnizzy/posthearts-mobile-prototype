import SwiftUI
import Foundation

enum ContentAlignment: String, CaseIterable, Identifiable {
    case top, center, bottom
    var id: String { rawValue }
    var label: String {
        switch self {
        case .top: return "Top"
        case .center: return "Center"
        case .bottom: return "Bottom"
        }
    }
}

@Observable
final class Letter: Identifiable, Hashable {
    let id: UUID = UUID()
    var title: String = ""
    var content: String = ""
    var contentAlignment: ContentAlignment = .top
    var paperId: String = "brown"
    var fontId: String = "Instrument Serif"
    var fontSizeStep: Int = 3       // 1...5, neutral = 3
    var frameColor: FrameColor = FrameColor.all.randomElement()!
    var addOns: [AddOn] = []
    let createdAt: Date = Date()
    var updatedAt: Date = Date()

    var paper: Paper { Paper.byId[paperId] ?? Paper.all[0] }
    var font: PostFont { PostFont.byId[fontId] ?? PostFont.all[0] }
    var typoScale: CGFloat { pow(1.15, CGFloat(fontSizeStep - 3)) }

    /// Title shown in the home grid: explicit title if set, otherwise first non-empty line of content.
    var displayTitle: String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmpty { return trimmedTitle }
        let firstLine = content
            .split(whereSeparator: \.isNewline)
            .first
            .map(String.init)?
            .trimmingCharacters(in: .whitespaces) ?? ""
        if firstLine.isEmpty { return "Untitled" }
        return String(firstLine.prefix(40))
    }

    static func == (lhs: Letter, rhs: Letter) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
