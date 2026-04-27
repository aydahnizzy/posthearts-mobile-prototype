import SwiftUI

extension Color {
    /// HSL → RGB. h: 0–360, s/l: 0–100, a: 0–1.
    init(h: Double, s: Double, l: Double, a: Double = 1) {
        let s_ = s / 100
        let l_ = l / 100
        let c = (1 - abs(2 * l_ - 1)) * s_
        let hh = h / 60
        let x = c * (1 - abs(hh.truncatingRemainder(dividingBy: 2) - 1))
        let m = l_ - c / 2
        var r = 0.0, g = 0.0, b = 0.0
        switch hh {
        case 0..<1: r = c; g = x
        case 1..<2: r = x; g = c
        case 2..<3: g = c; b = x
        case 3..<4: g = x; b = c
        case 4..<5: r = x; b = c
        default:    r = c; b = x
        }
        self.init(red: r + m, green: g + m, blue: b + m, opacity: a)
    }
}
