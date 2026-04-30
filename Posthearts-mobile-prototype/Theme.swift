import SwiftUI
import UIKit

/// Design-system color tokens exported from Figma (Light + Dark).
/// Each color resolves dynamically based on `userInterfaceStyle`.
enum Theme {
    enum Background {
        static let canvas    = dynamic(light: 0xF9F9F9, dark: 0x090909)
        static let onCanvas  = dynamic(light: 0xFFFFFF, dark: 0x121212)
        static let `default` = dynamic(light: 0xF0F0F0, dark: 0x212121)
        static let hover     = dynamic(light: 0xF0F0F0, dark: 0x2A2A2A)
        static let clicked   = dynamic(light: 0xE6E6E6, dark: 0x595959)
        static let primary   = dynamic(light: 0xE0E0F9, dark: 0xE0E0F9)
        static let positive  = dynamic(light: 0xD8E3FF, dark: 0x1F48B5)
        static let negative  = dynamic(light: 0xF9DDDD, dark: 0x9E0A05)
        static let success   = dynamic(light: 0xDAF1E2, dark: 0x036B26)
        static let warning   = dynamic(light: 0xFDEED4, dark: 0x865503)
    }

    enum Border {
        static let `default`     = dynamic(light: 0xF5F5F5, dark: 0x212121)
        static let onBg          = dynamic(light: 0xE6E6E6, dark: 0x2A2A2A)
        static let divider       = dynamic(light: 0xF0F0F0, dark: 0x2A2A2A)
        static let inputDefault  = dynamic(light: 0xE6E6E6, dark: 0x2A2A2A)
        static let inputHover    = dynamic(light: 0xD8D8D8, dark: 0x212121)
        static let inputActive   = dynamic(light: 0x2A2A2A, dark: 0xFFFFFF)
        static let inputNegative = dynamic(light: 0x9E0A05, dark: 0xF9DDDD)
    }

    enum Button {
        static let primary          = dynamic(light: 0x5C59ED, dark: 0x5C59ED)
        static let primaryHover     = dynamic(light: 0x3F3CCC, dark: 0x3F3CCC)
        static let destructive      = dynamic(light: 0xCB1A14, dark: 0xCB1A14)
        static let destructiveHover = dynamic(light: 0x9E0A05, dark: 0x9E0A05)
        static let neutral          = dynamic(light: 0xF0F0F0, dark: 0x3D3D3D)
        static let neutralHover     = dynamic(light: 0xE6E6E6, dark: 0x595959)
        static let disabled         = dynamic(light: 0xF0F0F0, dark: 0x2A2A2A)
    }

    enum Icon {
        static let primary        = dynamic(light: 0x8D8D8D, dark: 0x8D8D8D)
        static let secondary      = dynamic(light: 0xB2B2B2, dark: 0x595959)
        static let hover          = dynamic(light: 0x070707, dark: 0xF5F5F5)
        static let onPrimary      = dynamic(light: 0xFFFFFF, dark: 0xFFFFFF)
        static let positive       = dynamic(light: 0x1F48B5, dark: 0xD8E3FF)
        static let positiveOnDark = dynamic(light: 0x2C66FF, dark: 0xD8E3FF)
        static let negative       = dynamic(light: 0x9E0A05, dark: 0xF9DDDD)
        static let negativeOnDark = dynamic(light: 0xE26E6A, dark: 0xF9DDDD)
        static let success        = dynamic(light: 0x036B26, dark: 0xDAF1E2)
        static let successOnDark  = dynamic(light: 0x5FC381, dark: 0xDAF1E2)
        static let warning        = dynamic(light: 0x865503, dark: 0xFDEED4)
        static let warningOnDark  = dynamic(light: 0xDD900D, dark: 0xFDEED4)
    }

    enum Text {
        static let `default`       = dynamic(light: 0x070707, dark: 0xFFFFFF)
        static let secondary       = dynamic(light: 0x595959, dark: 0xB2B2B2)
        static let secondaryOnDark = dynamic(light: 0xD8D8D8, dark: 0xFFFFFF)
        static let tertiary        = dynamic(light: 0x8D8D8D, dark: 0x595959)
        static let onPrimary       = dynamic(light: 0xFFFFFF, dark: 0xFFFFFF)
        static let positive        = dynamic(light: 0x1F48B5, dark: 0xD8E3FF)
        static let positiveOnDark  = dynamic(light: 0x2C66FF, dark: 0xD8E3FF)
        static let negative        = dynamic(light: 0x9E0A05, dark: 0xF9DDDD)
        static let negativeOnDark  = dynamic(light: 0xE26E6A, dark: 0xF9DDDD)
        static let success         = dynamic(light: 0x036B26, dark: 0xDAF1E2)
        static let successOnDark   = dynamic(light: 0x5FC381, dark: 0xDAF1E2)
        static let warning         = dynamic(light: 0x865503, dark: 0xFDEED4)
        static let warningOnDark   = dynamic(light: 0xDD900D, dark: 0xFDEED4)
    }

    enum Tags {
        static let aBg   = dynamic(light: 0xC2F3E2, dark: 0x216E55)
        static let aText = dynamic(light: 0x216E55, dark: 0xC2F3E2)
        static let bBg   = dynamic(light: 0xCBFAF2, dark: 0x0C756E)
        static let bText = dynamic(light: 0x0C756E, dark: 0xCBFAF2)
        static let cBg   = dynamic(light: 0xFFEDD5, dark: 0xC23F09)
        static let cText = dynamic(light: 0xC23F09, dark: 0xFFEDD5)
        static let dBg   = dynamic(light: 0xF2FFD1, dark: 0x526E0C)
        static let dText = dynamic(light: 0x526E0C, dark: 0xF2FFD1)
        static let eBg   = dynamic(light: 0xECE9FE, dark: 0x6D28D8)
        static let eText = dynamic(light: 0x6D28D8, dark: 0xECE9FE)
        static let fBg   = dynamic(light: 0xFEF9C2, dark: 0xB8570B)
        static let fText = dynamic(light: 0xB8570B, dark: 0xFEF9C2)
        static let gBg   = dynamic(light: 0xE6DFEC, dark: 0x37364F)
        static let gText = dynamic(light: 0x37364F, dark: 0xE6DFEC)
        static let hBg   = dynamic(light: 0xFFCFD6, dark: 0xBD0F2C)
        static let hText = dynamic(light: 0xBD0F2C, dark: 0xFFCFD6)
    }

    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1
            )
        })
    }
}
