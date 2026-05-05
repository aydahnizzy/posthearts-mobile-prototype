import SwiftUI
import Combine

/// Mirrors the web `VoiceRecorder` pill: replaces the inputBar contents while
/// recording. During the `recording` state the left side shows an animated
/// waveform; in `processing`/`stopped` it shows shimmering status copy. Right
/// side is timer + cancel + (stop / restart). API is faked — `stop` triggers
/// a phrase-cycling delay then drops a sample transcript into `letter.content`.
///
/// State flow: `recording → stopped → processing → done` (returns to inputBar).
struct VoiceRecorderBar: View {
    @Bindable var letter: Letter
    @Binding var isActive: Bool
    var onTranscriptReady: (String) -> Void = { _ in }

    enum RecState { case recording, stopped, processing }
    @State private var state: RecState = .recording
    @State private var elapsedSeconds: Int = 0
    @State private var recordedSeconds: Int = 0
    @State private var phraseIndex: Int = 0
    @State private var phraseTask: Task<Void, Never>?

    private static let phrases = ["Gathering thoughts...", "Summarizing...", "Almost there..."]
    private let maxSeconds = 300
    private let warningThreshold = 270

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var processingLabel: String {
        Self.phrases[min(phraseIndex, Self.phrases.count - 1)]
    }

    private var isWarning: Bool { elapsedSeconds >= warningThreshold }

    private var timerText: String {
        if state == .recording {
            return String(format: "%d:%02d", elapsedSeconds / 60, elapsedSeconds % 60)
        } else {
            let mins = recordedSeconds / 60
            let secs = recordedSeconds % 60
            if recordedSeconds < 60      { return "\(recordedSeconds)s" }
            else if secs == 0            { return "\(mins)min" }
            else                         { return "\(mins)min \(secs)s" }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            // Left: waveform while recording, shimmering label otherwise.
            Group {
                if state == .recording {
                    AudioWaveform(isWarning: isWarning)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ZStack(alignment: .leading) {
                        ShimmerText(text: processingLabel)
                            .font(.system(size: 15))
                            .id(phraseIndex)
                            .transition(.phraseBlurFade)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 22)
                    .clipped()
                }
            }
            .padding(.leading, 16)

            HStack(spacing: 6) {
                NumberFlowText(text: timerText)
                    .font(.system(size: 13, weight: .regular))
                    .monospacedDigit()
                    .foregroundStyle(Theme.Text.default)
                    .padding(.trailing, 4)

                Button(action: cancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.Icon.hover)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)

                if state == .recording {
                    Button(action: stopRecording) {
                        ZStack {
                            Circle()
                                .fill(isWarning ? Color.red : Theme.Button.primary)
                                .frame(width: 32, height: 32)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.white)
                                .frame(width: 12, height: 12)
                        }
                    }
                    .buttonStyle(.plain)
                    .transition(.blurReplace)
                } else {
                    Button(action: restartRecording) {
                        Image("IconArrowRotateCounterClockwise")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Theme.Icon.hover)
                            .frame(width: 32, height: 32)
                            .background(Color.black.opacity(0.08), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .transition(.blurReplace)
                }
            }
            .padding(.trailing, 4)
            .animation(.smooth(duration: 0.15), value: state)
        }
        .frame(minHeight: 40)
        .background(
            Capsule().fill(state == .processing ? Theme.Background.onCanvas : Theme.Background.default)
        )
        .overlay {
            if state == .processing {
                ZStack {
                    AIGradientBorder(shape: Capsule(), lineWidth: 2)
                        .blur(radius: 3)
                        .clipShape(Capsule())
                    AIGradientBorder(shape: Capsule(), lineWidth: 1, outside: true)
                }
                .transition(.opacity)
                .allowsHitTesting(false)
            }
        }
        .onReceive(timer) { _ in
            guard state == .recording else { return }
            if elapsedSeconds < maxSeconds {
                elapsedSeconds += 1
            } else {
                stopRecording()
            }
        }
        .onDisappear {
            phraseTask?.cancel()
            phraseTask = nil
        }
    }

    private func stopRecording() {
        recordedSeconds = elapsedSeconds
        Haptics.impact(.light)
        beginProcessing()
    }

    private func beginProcessing() {
        phraseIndex = 0
        withAnimation(.smooth(duration: 0.25)) {
            state = .processing
        }

        // Phrase change uses the web's 0.3s slide-up + fade timing.
        let phraseAnim: Animation = .easeInOut(duration: 0.3)

        phraseTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            if Task.isCancelled { return }
            withAnimation(phraseAnim) { phraseIndex = 1 }

            try? await Task.sleep(for: .seconds(2))
            if Task.isCancelled { return }
            withAnimation(phraseAnim) { phraseIndex = 2 }

            try? await Task.sleep(for: .seconds(2))
            if Task.isCancelled { return }

            Haptics.notify(.success)
            onTranscriptReady(Self.fakeTranscript)
            withAnimation(.smooth(duration: 0.3)) {
                isActive = false
            }
        }
    }

    private func restartRecording() {
        phraseTask?.cancel()
        phraseTask = nil
        elapsedSeconds = 0
        recordedSeconds = 0
        phraseIndex = 0
        withAnimation(.smooth(duration: 0.2)) {
            state = .recording
        }
    }

    private func cancel() {
        phraseTask?.cancel()
        phraseTask = nil
        elapsedSeconds = 0
        recordedSeconds = 0
        phraseIndex = 0
        state = .recording
        withAnimation(.smooth(duration: 0.25)) {
            isActive = false
        }
    }

    private static let fakeTranscript = """
    I often find myself in awe of you — the way you smile, the sound of your laughter, the way your eyes light up when you're excited. It's in these little moments that I realize how lucky I am to call you mine. You're not just the person I love; you're my confidant, my biggest inspiration, and the one who makes my heart race with a simple glance.

    Thank you for being you — the most incredible person I've ever known. I love you more than words can ever express, but I'll spend the rest of my life trying to show you.

    Forever yours,
    Ayomidé
    """
}

// MARK: - Audio waveform

/// Animated waveform of vertical capsule bars with random-walk heights — fakes
/// the live audio level visualization in the design. Bars shift left every
/// tick, with a new bar appended on the right; gives a continuously scrolling
/// "live" feel without needing actual audio analysis.
private struct AudioWaveform: View {
    let isWarning: Bool

    /// 13 bars × 5pt wide + 12 × 2pt gaps = 89pt total — matches the
    /// Figma's wave layout.
    private static let barCount = 13
    private static let barWidth: CGFloat = 5
    private static let barSpacing: CGFloat = 2
    private static let waveHeight: CGFloat = 22
    private static let waveWidth: CGFloat =
        CGFloat(AudioWaveform.barCount) * AudioWaveform.barWidth
        + CGFloat(AudioWaveform.barCount - 1) * AudioWaveform.barSpacing

    @State private var bars: [CGFloat] = (0..<AudioWaveform.barCount).map { _ in
        CGFloat.random(in: 0.25...1.0)
    }
    private let tick = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var fill: AnyShapeStyle {
        if isWarning {
            return AnyShapeStyle(Color.red)
        }
        return AnyShapeStyle(Theme.Icon.secondary)
    }

    var body: some View {
        Rectangle()
            .fill(fill)
            .frame(width: Self.waveWidth, height: Self.waveHeight, alignment: .leading)
            .mask(
                HStack(spacing: Self.barSpacing) {
                    ForEach(0..<bars.count, id: \.self) { i in
                        Capsule()
                            .frame(width: Self.barWidth, height: max(Self.barWidth, bars[i] * Self.waveHeight))
                    }
                }
                .frame(width: Self.waveWidth, height: Self.waveHeight, alignment: .leading)
            )
            .onReceive(tick) { _ in
                withAnimation(.easeInOut(duration: 0.18)) {
                    bars.removeFirst()
                    bars.append(CGFloat.random(in: 0.25...1.0))
                }
            }
    }
}

// MARK: - Transitions

private extension AnyTransition {
    /// Tight blur+fade scoped to the transitioning view itself. Used for the
    /// rotating phrase texts so the swap reads as a soft cross-blur on just
    /// the text, not the surrounding pill.
    static var phraseBlurFade: AnyTransition {
        .modifier(
            active: PhraseBlurFadeModifier(blur: 2, opacity: 0),
            identity: PhraseBlurFadeModifier(blur: 0, opacity: 1)
        )
    }
}

private struct PhraseBlurFadeModifier: ViewModifier {
    let blur: CGFloat
    let opacity: Double
    func body(content: Content) -> some View {
        content.blur(radius: blur).opacity(opacity)
    }
}

// MARK: - NumberFlow text

/// SwiftUI port of the web's `@number-flow/react`. Splits `text` into
/// per-character slots; each digit slot is a vertical column of 0–9 that rolls
/// to the current value, while non-digit characters render statically. Inherits
/// font/foregroundStyle from the parent so callers style it like a normal Text.
private struct NumberFlowText: View {
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { _, char in
                if let digit = char.wholeNumberValue, (0...9).contains(digit) {
                    RollingDigit(value: digit)
                } else {
                    Text(String(char))
                }
            }
        }
    }
}

private struct RollingDigit: View {
    let value: Int
    @State private var slotSize: CGSize = .zero

    var body: some View {
        Text("0")
            .opacity(0)
            .onGeometryChange(for: CGSize.self) { $0.size } action: { slotSize = $0 }
            .overlay(alignment: .top) {
                if slotSize != .zero {
                    VStack(spacing: 0) {
                        ForEach(0..<10, id: \.self) { n in
                            Text("\(n)")
                                .frame(width: slotSize.width, height: slotSize.height)
                        }
                    }
                    .offset(y: -CGFloat(value) * slotSize.height)
                    .animation(.spring(response: 0.45, dampingFraction: 0.85), value: value)
                }
            }
            .clipped()
    }
}

// MARK: - AI gradient border

/// SwiftUI port of the web's `.ai-gradient-border` — a conic-gradient stroke
/// (cyan → cream → magenta → cyan) that rotates a full turn every 5s. Driven
/// by `TimelineView(.animation)` for guaranteed per-frame updates regardless
/// of withAnimation interpolation behaviour for ShapeStyles.
private struct AIGradientBorder<S: InsettableShape>: View {
    let shape: S
    let lineWidth: CGFloat
    /// Mirror's Figma's stroke alignment. `true` draws fully outside the
    /// shape's edge (inner edge of stroke = parent edge); `false` uses
    /// `.strokeBorder` and draws fully inside.
    var outside: Bool = false

    private let cycleDuration: Double = 5
    /// Backed by `@State` so the rotation phase survives the parent's body
    /// re-renders (e.g. when `phraseIndex` changes); a plain `let` would
    /// reinit to `Date()` on every recreation and snap the gradient back
    /// to 0° on every phrase swap.
    @State private var cycleStart = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(cycleStart)
            let progress = elapsed.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
            let rotation = Angle.degrees(progress * 360)
            let gradient = AngularGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: 0x66D0F7), location: 0.0),
                    .init(color: Color(hex: 0xFEEFC4), location: 0.3333),
                    .init(color: Color(hex: 0xE38AF6), location: 0.6666),
                    .init(color: Color(hex: 0x66D0F7), location: 1.0),
                ]),
                center: .center,
                startAngle: rotation,
                endAngle: rotation + .degrees(360)
            )
            if outside {
                // Outset the shape's frame by lineWidth/2 so a centered
                // `.stroke` lands fully outside the original edge.
                shape
                    .stroke(gradient, lineWidth: lineWidth)
                    .padding(-lineWidth / 2)
            } else {
                shape.strokeBorder(gradient, lineWidth: lineWidth)
            }
        }
    }
}

// MARK: - Shimmering text

/// SwiftUI port of the web's `ShimmeringText`. Base text sits in `#595959`,
/// and a wide white highlight band sweeps right→left across the entire phrase
/// every cycle. The text's `foregroundStyle` is set to a 5-stop horizontal
/// gradient whose locations track a `phase` driven by `TimelineView(.animation)`
/// — guaranteed per-frame updates so the highlight is always visibly moving,
/// regardless of withAnimation interpolation behaviour for ShapeStyles.
private struct ShimmerText: View {
    let text: String

    private let baseColor      = Color(hex: 0x595959)
    private let shimmerColor   = Color(hex: 0xF1F1F1)
    private let halfBand: CGFloat   = 0.30    // half-width of the bright band, [0–1]
    private let cycleDuration: Double = 3.0   // seconds per sweep
    private let cycleStart = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let phase = currentPhase(at: context.date)
            Text(text)
                .foregroundStyle(
                    LinearGradient(
                        stops: stops(phase: phase),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .id(text)
    }

    private func currentPhase(at date: Date) -> CGFloat {
        let elapsed = date.timeIntervalSince(cycleStart)
        let cycleProgress = elapsed.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
        let span = 1.0 + 2.0 * Double(halfBand)
        let phase = (1.0 + Double(halfBand)) - cycleProgress * span
        return CGFloat(phase)
    }

    private func stops(phase: CGFloat) -> [Gradient.Stop] {
        let lo  = max(0, min(1, phase - halfBand))
        let mid = max(0, min(1, phase))
        let hi  = max(0, min(1, phase + halfBand))
        // Locations must be non-decreasing.
        let l = min(lo, mid)
        let r = max(hi, mid)
        return [
            .init(color: baseColor,    location: 0),
            .init(color: baseColor,    location: l),
            .init(color: shimmerColor, location: mid),
            .init(color: baseColor,    location: r),
            .init(color: baseColor,    location: 1),
        ]
    }
}
