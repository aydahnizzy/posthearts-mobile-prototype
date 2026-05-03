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

    /// Compact relative time string for the home grid caption: "Now", "5m",
    /// "2h", "3d", "1w", "2mo", "1y".
    var timeAgoShort: String {
        let interval = max(0, Date().timeIntervalSince(updatedAt))
        if interval < 60 { return "Now" }
        let minutes = Int(interval / 60)
        if minutes < 60 { return "\(minutes)m" }
        let hours = Int(interval / 3600)
        if hours < 24 { return "\(hours)h" }
        let days = Int(interval / 86_400)
        if days < 7 { return "\(days)d" }
        let weeks = Int(interval / 604_800)
        if weeks < 4 { return "\(weeks)w" }
        let months = Int(interval / 2_592_000)
        if months < 12 { return "\(months)mo" }
        return "\(Int(interval / 31_536_000))y"
    }

    static func == (lhs: Letter, rhs: Letter) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
