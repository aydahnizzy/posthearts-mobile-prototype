import SwiftUI

struct LetterThumbnail: View {
    @Bindable var letter: Letter
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                LetterPreview(letter: letter, selectedAddOnId: .constant(nil), interactive: false)
                    .aspectRatio(5.0/7.0, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .allowsHitTesting(false)

                Text(letter.displayTitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.primary.opacity(0.75))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .buttonStyle(.plain)
    }
}
