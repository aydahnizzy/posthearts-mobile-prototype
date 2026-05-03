import SwiftUI
import Foundation

struct DatedLetterGroup: Identifiable {
    let id: String
    let label: String
    let order: Int
    let letters: [Letter]
}

@Observable
final class LettersStore {
    var letters: [Letter]

    init(seedSamples: Bool = true) {
        self.letters = seedSamples ? LettersStore.makeSampleLetters() : []
    }

    @discardableResult
    func create() -> Letter {
        let new = Letter()
        letters.insert(new, at: 0)
        return new
    }

    func delete(_ id: UUID) {
        letters.removeAll { $0.id == id }
    }

    @discardableResult
    func duplicate(_ letter: Letter) -> Letter {
        let copy = Letter()
        copy.title = letter.title
        copy.content = letter.content
        copy.contentAlignment = letter.contentAlignment
        copy.paperId = letter.paperId
        copy.fontId = letter.fontId
        copy.fontSizeStep = letter.fontSizeStep
        copy.frameColor = letter.frameColor
        copy.addOns = letter.addOns
        letters.insert(copy, at: 0)
        return copy
    }

    func touch(_ letter: Letter) {
        letter.updatedAt = Date()
    }

    /// Flat list of letters sorted by recency (newest first).
    /// Used by the simplified home grid where the date-grouped headers are gone.
    var sortedByRecency: [Letter] {
        letters.sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    /// Groups by recency, mirroring web's `groupLettersByDate` in lettersUtils.ts:
    /// today, yesterday, Last 7 Days, Last 30 Days, then by year (newest first).
    var grouped: [DatedLetterGroup] {
        let cal = Calendar.current
        let nowDay = cal.startOfDay(for: Date())
        let currentYear = cal.component(.year, from: Date())

        var today: [Letter] = []
        var yesterday: [Letter] = []
        var last7: [Letter] = []
        var last30: [Letter] = []
        var byYear: [Int: [Letter]] = [:]

        let sorted = letters.sorted(by: { $0.updatedAt > $1.updatedAt })
        for letter in sorted {
            let day = cal.startOfDay(for: letter.updatedAt)
            let diff = cal.dateComponents([.day], from: day, to: nowDay).day ?? 0
            switch diff {
            case ...0: today.append(letter)
            case 1: yesterday.append(letter)
            case 2...7: last7.append(letter)
            case 8...30: last30.append(letter)
            default:
                let y = cal.component(.year, from: letter.updatedAt)
                byYear[y, default: []].append(letter)
            }
        }

        var groups: [DatedLetterGroup] = []
        if !today.isEmpty     { groups.append(.init(id: "today",     label: "Today",        order: 0, letters: today)) }
        if !yesterday.isEmpty { groups.append(.init(id: "yesterday", label: "Yesterday",    order: 1, letters: yesterday)) }
        if !last7.isEmpty     { groups.append(.init(id: "last7",     label: "Last 7 days",  order: 2, letters: last7)) }
        if !last30.isEmpty    { groups.append(.init(id: "last30",    label: "Last 30 days", order: 3, letters: last30)) }
        for y in byYear.keys.sorted(by: >) {
            groups.append(.init(id: "year-\(y)", label: "\(y)", order: 4 + (currentYear - y), letters: byYear[y] ?? []))
        }
        return groups
    }

    // MARK: - Sample data

    private static func makeSampleLetters() -> [Letter] {
        let now = Date()
        let cal = Calendar.current
        func daysAgo(_ n: Int) -> Date {
            cal.date(byAdding: .day, value: -n, to: now) ?? now
        }

        let samples: [(content: String, paper: String, font: String, frame: FrameColor, age: Int, addOns: [AddOn])] = [
            (
                "I just wanted to take a moment to tell you how new pregnant you are. Every time I see you, I can't help but be amazed by your beauty.\n\nBeyond looks, I really like the way you talk. The way you express yourself is something I truly admire.\n\nLooking forward to getting to know you more.\n\nAyomide Daniel",
                "burnt-paper", "Marck Script", FrameColor.all[10], 0,
                [
                    addon(.emoji, "love-eyes", x: 380, y: -25, size: 100, rotation: 0.18),
                    addon(.sticker, "palmtree", x: 360, y: 540, size: 130, rotation: -0.14),
                ]
            ),
            (
                "Coucou mon bébé ❤️\n\nJ'espère que tu passeras une excellente semaine et que tu ne sentes pas trop stressée.\n\nJe serai toujours là pour t'écouter et t'aider du mieux que je peux, ma Shaylana.",
                "burnt-paper", "Instrument Serif", FrameColor.all[8], 0,
                [
                    addon(.emoji, "red-heart", x: 410, y: -10, size: 95, rotation: 0.25),
                ]
            ),
            (
                "Hoping to see you again soon. The garden is in full bloom and reminds me of the afternoon we spent there last spring.",
                "flowers", "Damion", FrameColor.all[2], 0,
                [
                    addon(.emoji, "butterfly", x: 400, y: 50, size: 100, rotation: 0.30),
                    addon(.emoji, "flower", x: -25, y: 480, size: 110, rotation: -0.20),
                ]
            ),
            (
                "She's just a girl. Reminding myself of that every morning.",
                "pink-stars", "Gloria Hallelujah", FrameColor.all[12], 0,
                [
                    addon(.emoji, "purple-heart", x: 410, y: 580, size: 100, rotation: 0.10),
                ]
            ),
            (
                "Hey love, just thinking of you today and wanted to send a little reminder that you're amazing.\n\n— A",
                "brown", "Marck Script", FrameColor.all[9], 1,
                [
                    addon(.emoji, "diamond-ring", x: 400, y: -15, size: 95, rotation: 0.20),
                    addon(.emoji, "rose", x: 380, y: 350, size: 105, rotation: -0.10),
                ]
            ),
            (
                "Mom, you mean the world to me. Thank you for everything you do.\n\nHappy birthday — I love you more than you'll ever know.",
                "lovers", "Damion", FrameColor.all[4], 3,
                [
                    addon(.emoji, "sunflower", x: -20, y: -20, size: 110, rotation: -0.18),
                    addon(.sticker, "sunflower-badge", x: 380, y: 540, size: 110, rotation: 0.12),
                ]
            ),
            (
                "B, my favorite human — happy birthday! Hope this year is your softest one yet.",
                "brown", "Mansalva", FrameColor.all[10], 5,
                [
                    addon(.emoji, "balloon", x: 410, y: -20, size: 95, rotation: 0.22),
                    addon(.emoji, "purple-heart", x: -15, y: 560, size: 90, rotation: -0.16),
                ]
            ),
            (
                "Do you remember that trip when we kept missing the train and ended up walking through that little town at midnight? I think about it more than I should.",
                "old-flower", "Inria Serif", FrameColor.all[1], 14,
                [
                    addon(.sticker, "palmtree", x: 380, y: 540, size: 120, rotation: 0.10),
                    addon(.sticker, "sun-hat", x: -20, y: -10, size: 100, rotation: -0.18),
                ]
            ),
            (
                "miss you luv.\n\nThe coffee at our spot tastes wrong without you. Come back soon.",
                "kisses", "Mansalva", FrameColor.all[8], 22,
                [
                    addon(.emoji, "red-heart", x: -20, y: 560, size: 100, rotation: -0.20),
                ]
            ),
            (
                "10 years today. Still the best thing I ever said yes to.",
                "red-end", "Marck Script", FrameColor.all[9], 28,
                [
                    addon(.emoji, "diamond-ring", x: 180, y: -15, size: 110, rotation: 0),
                    addon(.emoji, "radiating-heart", x: 400, y: 320, size: 100, rotation: 0.18),
                ]
            ),
            (
                "It's been a while since I've written. Wanted to say hi and tell you I miss our long talks.",
                "pink", "Inria Serif", FrameColor.all[11], 35,
                [
                    addon(.emoji, "butterfly", x: 410, y: 30, size: 95, rotation: 0.20),
                    addon(.emoji, "flower", x: 380, y: 540, size: 100, rotation: -0.12),
                ]
            ),
            (
                "Wishing you the happiest of days! Save me a slice. 🎂",
                "carton", "Gloria Hallelujah", FrameColor.all[4], 45,
                [
                    addon(.sticker, "lollipop", x: 400, y: -15, size: 110, rotation: 0.25),
                    addon(.sticker, "donut", x: -20, y: 540, size: 110, rotation: -0.20),
                ]
            ),
        ]

        return samples.map { sample in
            let l = Letter()
            l.content = sample.content
            l.paperId = sample.paper
            l.fontId = sample.font
            l.frameColor = sample.frame
            l.updatedAt = daysAgo(sample.age)
            l.addOns = sample.addOns
            return l
        }
    }

    /// Convenience for seeding sample add-ons in design-unit coordinates.
    private static func addon(
        _ kind: AddOnKind,
        _ name: String,
        x: CGFloat,
        y: CGFloat,
        size: CGFloat = 110,
        rotation: Double = 0
    ) -> AddOn {
        AddOn(
            kind: kind,
            assetName: name,
            position: CGPoint(x: x, y: y),
            size: CGSize(width: size, height: size),
            rotation: rotation
        )
    }
}
