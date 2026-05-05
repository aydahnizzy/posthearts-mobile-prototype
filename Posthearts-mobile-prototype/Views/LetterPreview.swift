import SwiftUI
import UIKit

/// The "frame" — a fixed-dimension card with `frameColor` background that contains
/// the paper, rendered text, and add-ons. Read-only: text is edited via `LetterInput`.
struct LetterPreview: View {
    @Bindable var letter: Letter
    @Binding var selectedAddOnId: UUID?
    /// When false, gestures are disabled (used for thumbnails).
    var interactive: Bool = true

    /// Outer rounded-rect radius applied to the colored frame. Editors want
    /// the full 24pt look; small thumbnails should pass a smaller value (e.g.
    /// 8pt) so the frame doesn't dominate the cell visually.
    var frameCornerRadius: CGFloat = 24

    @State private var jiggleStep: Int = -1

    /// Internal padding between the frame edge and the paper, expressed as a
    /// fraction of the frame's width/height. 12.5% on each axis matches the web's
    /// `grid-template-columns: 12.5% 75% 12.5%` chrome.
    private let framePaddingFraction: CGFloat = 0.125

    private let jiggleAngles: [Double] = [-0.5, 1.0, -1.0, 0.5]
    private var jiggleAngle: Double {
        jiggleStep >= 0 ? jiggleAngles[jiggleStep % jiggleAngles.count] : 0
    }

    var body: some View {
        GeometryReader { proxy in
            let frameW = proxy.size.width
            let frameH = proxy.size.height

            // Fit paper inside the frame respecting both axes.
            let availW = frameW * (1 - 2 * framePaddingFraction)
            let availH = frameH * (1 - 2 * framePaddingFraction)
            let widthBound = availW / PaperGeometry.aspect <= availH
            let paperW: CGFloat = widthBound ? availW : availH * PaperGeometry.aspect
            let paperH: CGFloat = widthBound ? availW / PaperGeometry.aspect : availH
            let scale = paperW / PaperGeometry.designWidth   // --su

            ZStack {
                // Frame background
                RoundedRectangle(cornerRadius: frameCornerRadius)
                    .fill(letter.frameColor.color)
                    .animation(.easeInOut(duration: 0.3), value: letter.frameColor)

                // Paper + add-ons jiggle on frameColor change. The rotation cycles
                // through [-0.5°, 1°, -1°, 0.5°] — one step per change — so successive
                // changes alternate between resting tilts.
                ZStack {
                    paperBaseLayer(width: paperW, height: paperH, scale: scale)
                    addOnsLayer(width: paperW, height: paperH, scale: scale)
                }
                .rotationEffect(.degrees(jiggleAngle))
                .animation(.easeInOut(duration: 0.4), value: jiggleStep)
                .onChange(of: letter.frameColor) { _, _ in
                    jiggleStep += 1
                }
            }
            .frame(width: frameW, height: frameH)
            .compositingGroup()
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
                // Capture the id by value so the delete closure doesn't go
                // through the binding (which becomes invalid the instant the
                // element is removed from the array).
                let id = addOn.id
                AddOnView(
                    addOn: $addOn,
                    scale: scale,
                    isSelected: selectedAddOnId == id,
                    interactive: interactive,
                    onSelect: { selectedAddOnId = id },
                    onDelete: {
                        letter.addOns.removeAll { $0.id == id }
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
