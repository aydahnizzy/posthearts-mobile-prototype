import SwiftUI

struct ComposeCard: View {
    @Bindable var letter: Letter
    @FocusState.Binding var focused: Bool
    var onExpand: () -> Void = {}
    var onClear: () -> Void = {}
    var onSubmit: () -> Void = {}

    @State private var contentHeight: CGFloat = 0

    private let compactHeight: CGFloat = 108
    private let maxHeight: CGFloat = 429
    private let multilineChrome: CGFloat = 128
    private let singleLineThreshold: CGFloat = 28
    private var multilineTextCap: CGFloat { maxHeight - multilineChrome } // 301

    private var hasText: Bool { !letter.content.isEmpty }
    private var isMultiline: Bool { contentHeight > singleLineThreshold }

    private var cardHeight: CGFloat {
        guard isMultiline else { return compactHeight }
        return min(maxHeight, multilineChrome + min(contentHeight, multilineTextCap))
    }

    var body: some View {
        VStack(spacing: 0) {
            grabber
            VStack(spacing: 20) {
                header
                inputRow
                if isMultiline {
                    actionRow
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(height: cardHeight, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Theme.Background.onCanvas)
                .shadow(color: Color(hex: 0x2A2A2A, alpha: 0.10), radius: 12, x: 0, y: 4)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: cardHeight)
        .animation(.easeInOut(duration: 0.15), value: hasText)
    }

    private var grabber: some View {
        Capsule()
            .fill(Color(hex: 0xD9D9D9))
            .frame(width: 29, height: 4)
            .frame(height: 12)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("Express how you feel")
                .font(.system(size: 15))
                .foregroundStyle(Theme.Text.tertiary)
            Spacer(minLength: 0)
            Button(action: onExpand) {
                Image("IconExpand45")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Theme.Icon.hover)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 24)
    }

    private var inputRow: some View {
        HStack(spacing: 8) {
            ZStack(alignment: .topLeading) {
                if !hasText {
                    Text("Start writing...")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.Text.tertiary)
                        .allowsHitTesting(false)
                }
                TextField("", text: $letter.content, axis: .vertical)
                    .focused($focused)
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.Text.default)
                    .tint(Theme.Text.default)
                    .lineLimit(isMultiline ? nil : 1)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .frame(maxHeight: isMultiline ? multilineTextCap : 32, alignment: .topLeading)
            .background(measurementOverlay)

            if !isMultiline {
                trailingCompactButton
            }
        }
        .frame(maxHeight: isMultiline ? multilineTextCap : 32, alignment: .top)
    }

    @ViewBuilder
    private var trailingCompactButton: some View {
        if hasText {
            submitButton
        } else {
            voiceButton
        }
    }

    private var submitButton: some View {
        Button(action: onSubmit) {
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Theme.Button.primary, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private var voiceButton: some View {
        Button {
            // voice action
        } label: {
            Image("voice")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(Theme.Icon.hover)
                .frame(width: 32, height: 32)
                .background(Theme.Border.inputHover, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private var actionRow: some View {
        HStack {
            Button(action: onClear) {
                Image("trash-can")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Theme.Icon.hover)
                    .frame(width: 32, height: 32)
                    .background(Theme.Border.inputHover, in: Circle())
            }
            .buttonStyle(.plain)
            Spacer(minLength: 0)
            submitButton
        }
        .frame(height: 32)
    }

    private var measurementOverlay: some View {
        GeometryReader { geo in
            Text(letter.content.isEmpty ? "Start writing..." : letter.content)
                .font(.system(size: 15))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: geo.size.width, alignment: .leading)
                .background(
                    GeometryReader { textGeo in
                        Color.clear
                            .preference(key: ComposeContentHeightKey.self, value: textGeo.size.height)
                    }
                )
                .opacity(0)
                .allowsHitTesting(false)
        }
        .onPreferenceChange(ComposeContentHeightKey.self) { contentHeight = $0 }
    }
}

private struct ComposeContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
