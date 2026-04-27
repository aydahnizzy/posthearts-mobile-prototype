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
    var letters: [Letter] = []

    @discardableResult
    func create() -> Letter {
        let new = Letter()
        letters.insert(new, at: 0)
        return new
    }

    func delete(_ id: UUID) {
        letters.removeAll { $0.id == id }
    }

    func touch(_ letter: Letter) {
        letter.updatedAt = Date()
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
}
