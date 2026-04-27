import SwiftUI
import UIKit
import Foundation

struct AddOnView: View {
    @Binding var addOn: AddOn
    let scale: CGFloat               // su: pixels-per-design-unit
    let isSelected: Bool
    var interactive: Bool = true
    let onSelect: () -> Void
    let onDelete: () -> Void

    // Live gesture deltas, applied on top of stored state.
    @State private var dragOffset: CGSize = .zero
    @State private var pinchScale: CGFloat = 1.0
    @State private var spinDelta: Double = 0
    @State private var resizeFactor: CGFloat = 1.0   // live during corner-handle drag

    private var displayWidth: CGFloat { addOn.size.width * scale * pinchScale * resizeFactor }
    private var displayHeight: CGFloat { addOn.size.height * scale * pinchScale * resizeFactor }
    private var totalRotation: Double { addOn.rotation + spinDelta }

    var body: some View {
        Image(uiImage: UIImage(named: addOn.assetName) ?? UIImage())
            .resizable()
            .scaledToFit()
            .frame(width: displayWidth, height: displayHeight)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .clear)
                    .padding(-6)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white, .black.opacity(0.7))
                    }
                    .offset(x: 14, y: -14)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if isSelected {
                    resizeHandle.offset(x: 14, y: 14)
                }
            }
            .rotationEffect(.radians(totalRotation))
            .position(
                x: addOn.position.x * scale + addOn.size.width * scale / 2 + dragOffset.width,
                y: addOn.position.y * scale + addOn.size.height * scale / 2 + dragOffset.height
            )
            .if(interactive) { view in
                view
                    .onTapGesture { onSelect() }
                    .gesture(
                        DragGesture()
                            .onChanged { v in
                                if !isSelected { onSelect() }
                                dragOffset = v.translation
                            }
                            .onEnded { v in
                                addOn.position.x += v.translation.width / scale
                                addOn.position.y += v.translation.height / scale
                                dragOffset = .zero
                            }
                    )
                    .simultaneousGesture(
                        MagnificationGesture()
                            .onChanged { s in
                                if !isSelected { onSelect() }
                                pinchScale = s
                            }
                            .onEnded { s in
                                addOn.size.width *= s
                                addOn.size.height *= s
                                pinchScale = 1
                            }
                    )
                    .simultaneousGesture(
                        RotationGesture()
                            .onChanged { a in
                                if !isSelected { onSelect() }
                                spinDelta = a.radians
                            }
                            .onEnded { a in
                                addOn.rotation += a.radians
                                spinDelta = 0
                            }
                    )
            }
    }

    /// Bottom-right corner handle. Drag away from add-on center to enlarge,
    /// toward center to shrink. Aspect ratio is preserved.
    private var resizeHandle: some View {
        Circle()
            .fill(.white)
            .frame(width: 28, height: 28)
            .overlay(
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.black.opacity(0.65))
            )
            .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
            .contentShape(Circle())
            .highPriorityGesture(
                DragGesture()
                    .onChanged { v in
                        if !isSelected { onSelect() }
                        let halfW = Double(addOn.size.width * scale / 2)
                        let halfH = Double(addOn.size.height * scale / 2)
                        let theta = totalRotation
                        // Original handle position relative to add-on center, in screen space.
                        let hx0 = halfW * Foundation.cos(theta) - halfH * Foundation.sin(theta)
                        let hy0 = halfW * Foundation.sin(theta) + halfH * Foundation.cos(theta)
                        let hx = hx0 + Double(v.translation.width)
                        let hy = hy0 + Double(v.translation.height)
                        let newDist = (hx * hx + hy * hy).squareRoot()
                        let origDist = (halfW * halfW + halfH * halfH).squareRoot()
                        resizeFactor = max(0.25, min(5.0, newDist / max(origDist, 0.0001)))
                    }
                    .onEnded { _ in
                        addOn.size.width *= resizeFactor
                        addOn.size.height *= resizeFactor
                        resizeFactor = 1
                    }
            )
    }
}
