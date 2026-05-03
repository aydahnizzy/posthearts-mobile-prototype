import SwiftUI

struct LetterThumbnail: View {
    @Bindable var letter: Letter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LetterPreview(
                letter: letter,
                selectedAddOnId: .constant(nil),
                interactive: false,
                frameCornerRadius: 12
            )
            .aspectRatio(850.0/1069.0, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .allowsHitTesting(false)

            captionRow
        }
        .contentShape(Rectangle())
    }

    private var captionRow: some View {
        Text(letter.displayTitle)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Theme.Text.tertiary)
            .tracking(0.1)
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PressableScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
