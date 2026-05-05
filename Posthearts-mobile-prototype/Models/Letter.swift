import SwiftUI
import Foundation

enum ContentAlignment: String, CaseIterable, Identifiable, Codable {
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
final class Letter: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var content: String
    var contentAlignment: ContentAlignment
    var paperId: String
    var fontId: String
    var fontSizeStep: Int       // 1...5, neutral = 3
    var frameColor: FrameColor
    var addOns: [AddOn]
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        contentAlignment: ContentAlignment = .top,
        paperId: String = "brown",
        fontId: String = "Instrument Serif",
        fontSizeStep: Int = 3,
        frameColor: FrameColor = FrameColor.all.randomElement()!,
        addOns: [AddOn] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.contentAlignment = contentAlignment
        self.paperId = paperId
        self.fontId = fontId
        self.fontSizeStep = fontSizeStep
        self.frameColor = frameColor
        self.addOns = addOns
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, title, content, contentAlignment, paperId, fontId,
             fontSizeStep, frameColor, addOns, createdAt, updatedAt
    }

    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try c.decode(UUID.self, forKey: .id),
            title: try c.decode(String.self, forKey: .title),
            content: try c.decode(String.self, forKey: .content),
            contentAlignment: try c.decode(ContentAlignment.self, forKey: .contentAlignment),
            paperId: try c.decode(String.self, forKey: .paperId),
            fontId: try c.decode(String.self, forKey: .fontId),
            fontSizeStep: try c.decode(Int.self, forKey: .fontSizeStep),
            frameColor: try c.decode(FrameColor.self, forKey: .frameColor),
            addOns: try c.decode([AddOn].self, forKey: .addOns),
            createdAt: try c.decode(Date.self, forKey: .createdAt),
            updatedAt: try c.decode(Date.self, forKey: .updatedAt)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(content, forKey: .content)
        try c.encode(contentAlignment, forKey: .contentAlignment)
        try c.encode(paperId, forKey: .paperId)
        try c.encode(fontId, forKey: .fontId)
        try c.encode(fontSizeStep, forKey: .fontSizeStep)
        try c.encode(frameColor, forKey: .frameColor)
        try c.encode(addOns, forKey: .addOns)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(updatedAt, forKey: .updatedAt)
    }

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
