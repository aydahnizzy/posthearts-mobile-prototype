import SwiftUI
import UIKit

/// The "frame" — a fixed-dimension card with `frameColor` background that contains
/// the paper, rendered text, and add-ons. Read-only: text is edited via `LetterInput`.
struct LetterPreview: View {
    @Bindable var letter: Letter
    @Binding var selectedAddOnId: UUID?
    /// When false, gestures are disabled (used for thumbnails).
    var interactive: Bool = true

    /// Internal padding between the frame edge and the paper.
    private let framePaddingH: CGFloat = 18
    private let framePaddingV: CGFloat = 22
    private let frameCornerRadius: CGFloat = 24

    var body: some View {
        GeometryReader { proxy in
            let frameW = proxy.size.width
            let frameH = proxy.size.height

            // Fit paper inside the frame respecting both axes.
            let availW = frameW - 2 * framePaddingH
            let availH = frameH - 2 * framePaddingV
            let widthBound = availW / PaperGeometry.aspect <= availH
            let paperW: CGFloat = widthBound ? availW : availH * PaperGeometry.aspect
            let paperH: CGFloat = widthBound ? availW / PaperGeometry.aspect : availH
            let scale = paperW / PaperGeometry.designWidth   // --su

            ZStack {
                // Frame background
                RoundedRectangle(cornerRadius: frameCornerRadius)
                    .fill(letter.frameColor.color)
                    .animation(.easeInOut(duration: 0.3), value: letter.frameColor)

                // Paper texture + text — clipped to the paper's rounded rect.
                paperBaseLayer(width: paperW, height: paperH, scale: scale)

                // Add-ons — share the paper's coordinate space but are NOT clipped to it,
                // so they can extend onto the frame background. Only the outer frame
                // (.clipShape below) constrains them.
                addOnsLayer(width: paperW, height: paperH, scale: scale)
            }
            .frame(width: frameW, height: frameH)
            .clipShape(RoundedRectangle(cornerRadius: frameCornerRadius))
            .contentShape(RoundedRectangle(cornerRadius: frameCornerRadius))
            .if(interactive) { view in
                view.onTapGesture { selectedAddOnId = nil }
            }
        }
    }

    @ViewBuilder
    private func paperBaseLayer(width: CGFloat, height: CGFloat, scale: CGFloat) -> some View {
        ZStack {
            Image(uiImage: UIImage(named: letter.paper.id) ?? UIImage())
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()

            textLayer(width: width, height: height, scale: scale)
        }
        .frame(width: width, height: height)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: letter.paper.cornerRadius * scale))
        .shadow(color: .black.opacity(0.18), radius: 18 * scale, x: 0, y: 6 * scale)
    }

    @ViewBuilder
    private func addOnsLayer(width: CGFloat, height: CGFloat, scale: CGFloat) -> some View {
        ZStack {
            Color.clear
            ForEach($letter.addOns) { $addOn in
                AddOnView(
                    addOn: $addOn,
                    scale: scale,
                    isSelected: selectedAddOnId == addOn.id,
                    interactive: interactive,
                    onSelect: { selectedAddOnId = addOn.id },
                    onDelete: {
                        letter.addOns.removeAll { $0.id == addOn.id }
                        selectedAddOnId = nil
                    }
                )
            }
        }
        .frame(width: width, height: height)
    }

    @ViewBuilder
    private func textLayer(width: CGFloat, height: CGFloat, scale: CGFloat) -> some View {
        let p = letter.paper.padding
        let alignment: Alignment = {
            switch letter.contentAlignment {
            case .top: return .topLeading
            case .center: return .leading
            case .bottom: return .bottomLeading
            }
        }()
        let font = letter.font
        let textColor = letter.paper.textColor ?? .black

        ZStack(alignment: alignment) {
            Color.clear
            Text(letter.content.isEmpty ? " " : letter.content)
                .font(font.swiftUIFont(scale: scale * letter.typoScale))
                .foregroundStyle(textColor)
                .tracking(font.letterSpacing * scale * letter.typoScale)
                .lineSpacing(max(0, (font.baseLineHeight - font.baseSize) * scale * letter.typoScale))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(EdgeInsets(
            top: p.top * scale,
            leading: p.leading * scale,
            bottom: p.bottom * scale,
            trailing: p.trailing * scale
        ))
        .frame(width: width, height: height, alignment: alignment)
        .allowsHitTesting(false)
    }
}
