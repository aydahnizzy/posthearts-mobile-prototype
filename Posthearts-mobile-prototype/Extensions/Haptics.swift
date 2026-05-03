import UIKit

/// Tiny wrapper around the UIKit haptic generators for one-shot feedback inside
/// button actions or other imperative callbacks. For state-driven haptics
/// (a value just changed), prefer SwiftUI's `.sensoryFeedback(_:trigger:)`.
@MainActor
enum Haptics {
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
