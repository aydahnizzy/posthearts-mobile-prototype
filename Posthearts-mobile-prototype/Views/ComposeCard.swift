import SwiftUI

struct ComposeCard: View {
    @Bindable var letter: Letter
    @FocusState.Binding var focused: Bool
    var onExpand: () -> Void = {}
    var onClear: () -> Void = {}
    var onSubmit: () -> Void = {}

    /// Cap on the input area's height before it starts scrolling internally.
    private let inputMaxHeight: CGFloat = 280

    private var hasText: Bool { !letter.content.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            grabber
            VStack(spacing: 16) {
                header
                inputRow
                actionRow
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .animation(.easeInOut(duration: 0.15), value: hasText)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Theme.Background.onCanvas)
            .shadow(color: Color(hex: 0x2A2A2A, alpha: 0.10), radius: 12, x: 0, y: 4)
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
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(maxHeight: inputMaxHeight, alignment: .topLeading)
    }

    private var actionRow: some View {
        HStack(spacing: 0) {
            Button(action: onClear) {
                Image("trash-can")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Theme.Icon.primary)
                    .frame(width: 32, height: 32)
                    .background(Theme.Border.inputHover, in: Circle())
            }
            .buttonStyle(.plain)
            .opacity(hasText ? 1 : 0)
            .disabled(!hasText)

            Spacer(minLength: 0)

            if hasText {
                submitButton
            } else {
                voiceButton
            }
        }
        .frame(height: 32)
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
}
