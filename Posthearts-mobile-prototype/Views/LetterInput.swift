import SwiftUI

/// Separate text input that drives `letter.content`. Mirrors the web's LetterInput pane.
struct LetterInput: View {
    @Bindable var letter: Letter
    @FocusState private var focused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Visual container
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "pencil.line")
                        .foregroundStyle(.secondary)
                    Text("Write your letter")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    if focused {
                        Button("Done") { focused = false }
                            .font(.system(size: 13, weight: .semibold))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)

                TextEditor(text: $letter.content)
                    .focused($focused)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .font(letter.font.swiftUIFont(scale: letter.typoScale))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
        }
    }
}
