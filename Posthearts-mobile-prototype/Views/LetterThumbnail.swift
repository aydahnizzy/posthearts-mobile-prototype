import SwiftUI

struct LetterThumbnail: View {
    @Bindable var letter: Letter

    var body: some View {
        VStack(spacing: 8) {
            LetterPreview(letter: letter, selectedAddOnId: .constant(nil), interactive: false)
                .aspectRatio(850.0/1069.0, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .allowsHitTesting(false)

            Text(letter.displayTitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.Text.secondary)
                .tracking(0.1)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: 100)
        }
        .contentShape(Rectangle())
    }
}

struct PressableScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
