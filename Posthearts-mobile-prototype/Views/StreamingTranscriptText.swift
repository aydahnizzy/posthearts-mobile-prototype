import SwiftUI
import Combine

/// Read-only view that streams `text` in character-by-character with an
/// AI-chatbox-style leading-edge blur+fade. Owns its own `ScrollView` and
/// auto-scrolls so the leading edge stays in view as the reveal advances —
/// the user doesn't need to follow it manually. Calls `onComplete` once the
/// entire string (plus the fade window) has been revealed.
struct StreamingTranscriptText: View {
    let text: String
    var font: Font = .system(size: 16)
    var foregroundColor: Color = Theme.Text.default
    var lineSpacing: CGFloat = 5
    let onComplete: () -> Void

    @State private var startDate: Date = .distantFuture
    @State private var completionTask: Task<Void, Never>?

    /// Approximate characters per second of reveal.
    private let revealRate: Double = 120

    /// Auto-scroll cadence — fast enough to feel like the scroll is following
    /// the leading edge, slow enough to avoid hammering scroll updates.
    private let scrollTimer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

    /// Subtle haptic tick while the reveal is in progress — gives the stream
    /// a tactile pulse without overwhelming the user.
    private let hapticTimer = Timer.publish(every: 0.18, on: .main, in: .common).autoconnect()

    private var totalChars: Double {
        Double(text.count) + StreamingBlurRenderer.fadeWindow
    }

    private func visible(at date: Date) -> Double {
        let elapsed = max(0, date.timeIntervalSince(startDate))
        return min(elapsed * revealRate, totalChars)
    }

    private func displayedText(forVisible v: Double) -> String {
        let cutoff = min(
            Int(v) + Int(StreamingBlurRenderer.fadeWindow) + 1,
            text.count
        )
        return String(text.prefix(cutoff))
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                TimelineView(.animation) { context in
                    let v = visible(at: context.date)
                    Text(displayedText(forVisible: v))
                        .font(font)
                        .lineSpacing(lineSpacing)
                        .foregroundStyle(foregroundColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textRenderer(StreamingBlurRenderer(visible: v))
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                }
                Color.clear.frame(height: 1).id("bottom")
            }
            .onReceive(scrollTimer) { _ in
                // Stop following once the reveal is complete so the user can
                // scroll up freely without being yanked back.
                let v = visible(at: Date())
                guard v < totalChars else { return }
                // No `withAnimation` wrapper — at 80ms cadence each new
                // scroll would interrupt the previous animation mid-flight,
                // making the position effectively never settle. Snapping
                // instantly each tick reads as a smooth follow.
                proxy.scrollTo("bottom", anchor: .bottom)
            }
            .onReceive(hapticTimer) { _ in
                let v = visible(at: Date())
                guard v > 0 && v < totalChars else { return }
                Haptics.selection()
            }
        }
        .onAppear {
            startDate = Date()
            completionTask = Task { @MainActor in
                let duration = totalChars / revealRate
                try? await Task.sleep(for: .seconds(duration))
                if Task.isCancelled { return }
                onComplete()
            }
        }
        .onDisappear {
            completionTask?.cancel()
            completionTask = nil
        }
    }
}

/// `TextRenderer` that draws the layout per-glyph with a leading-edge fade:
///   • glyphs at index `< visible - fadeWindow` render fully opaque
///   • glyphs in `[visible - fadeWindow, visible)` render with fading opacity
///     (clearest at the older end, ghosting in at the leading edge)
///   • glyphs at index `>= visible` are not drawn at all
/// Mirrors the ChatGPT-style reveal: pure opacity fade, no blur.
struct StreamingBlurRenderer: TextRenderer {
    static let fadeWindow: Double = 28

    var visible: Double

    var animatableData: Double {
        get { visible }
        set { visible = newValue }
    }

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        var pos: Double = 0
        for line in layout {
            for run in line {
                for slice in run {
                    let distance = visible - pos
                    if distance >= Self.fadeWindow {
                        ctx.draw(slice)
                    } else if distance > 0 {
                        let t = distance / Self.fadeWindow
                        var sub = ctx
                        sub.opacity = t
                        sub.draw(slice)
                    }
                    pos += 1
                }
            }
        }
    }
}
