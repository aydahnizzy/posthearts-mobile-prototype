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
    @State private var resizeFactor: CGFloat = 1.0

    // Selection chrome metrics — mirror the web wireframe.
    private let outlinePadding: CGFloat = 10
    private let outlineStroke: CGFloat = 2
    private let cornerHandleSize: CGFloat = 12
    private let chipSize: CGFloat = 28
    private let chipGap: CGFloat = 6
    private var accent: Color { Theme.Button.primary }

    private var displayWidth: CGFloat { addOn.size.width * scale * pinchScale * resizeFactor }
    private var displayHeight: CGFloat { addOn.size.height * scale * pinchScale * resizeFactor }
    private var totalRotation: Double { addOn.rotation + spinDelta }
    private var outerWidth: CGFloat { displayWidth + outlinePadding * 2 }
    private var outerHeight: CGFloat { displayHeight + outlinePadding * 2 }

    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: addOn.assetName) ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: displayWidth, height: displayHeight)

            if isSelected && interactive {
                selectionChrome
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
                .gesture(moveGesture)
                .simultaneousGesture(pinchGesture)
                .simultaneousGesture(twoFingerRotationGesture)
        }
    }

    // MARK: - Selection chrome (matches web wireframe)

    @ViewBuilder
    private var selectionChrome: some View {
        // 2px solid accent outline with 10pt padding around the addon.
        Rectangle()
            .strokeBorder(accent, lineWidth: outlineStroke)
            .frame(width: outerWidth, height: outerHeight)
            .allowsHitTesting(false)

        // Four corner handles. Bottom-right is also the resize gesture target —
        // the others are visual for now (pinch still resizes).
        cornerHandle.offset(x: -outerWidth / 2, y: -outerHeight / 2)
        cornerHandle.offset(x:  outerWidth / 2, y: -outerHeight / 2)
        cornerHandle.offset(x: -outerWidth / 2, y:  outerHeight / 2)
        cornerHandle
            .offset(x: outerWidth / 2, y: outerHeight / 2)
            .highPriorityGesture(resizeGesture)

        // Top-center trash chip.
        chip(systemImage: "trash")
            .highPriorityGesture(
                TapGesture().onEnded { onDelete() }
            )
            .offset(y: -outerHeight / 2 - chipSize / 2 - chipGap)

        // Bottom-center rotate chip.
        chip(systemImage: "arrow.clockwise")
            .highPriorityGesture(rotateHandleGesture)
            .offset(y: outerHeight / 2 + chipSize / 2 + chipGap)
    }

    private var cornerHandle: some View {
        Rectangle()
            .fill(.white)
            .frame(width: cornerHandleSize, height: cornerHandleSize)
            .overlay(
                Rectangle().stroke(accent, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }

    private func chip(systemImage: String) -> some View {
        Circle()
            .fill(.white)
            .frame(width: chipSize, height: chipSize)
            .overlay(
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.85))
            )
            .shadow(color: .black.opacity(0.18), radius: 3, x: 0, y: 1)
            .contentShape(Circle())
    }

    // MARK: - Gestures

    private var moveGesture: some Gesture {
        DragGesture()
            .onChanged { v in
                if !isSelected { onSelect() }
                let proposed = CGPoint(
                    x: addOn.position.x + v.translation.width / scale,
                    y: addOn.position.y + v.translation.height / scale
                )
                let clamped = clampPosition(proposed)
                dragOffset = CGSize(
                    width: (clamped.x - addOn.position.x) * scale,
                    height: (clamped.y - addOn.position.y) * scale
                )
            }
            .onEnded { v in
                let proposed = CGPoint(
                    x: addOn.position.x + v.translation.width / scale,
                    y: addOn.position.y + v.translation.height / scale
                )
                addOn.position = clampPosition(proposed)
                dragOffset = .zero
            }
    }

    /// Frame extends 12.5% past the paper on each side. Add-on position is the
    /// add-on's top-left corner in design units; we keep its bounding box inside
    /// that extended frame so it never crosses the colored chrome edge.
    private func clampPosition(_ p: CGPoint) -> CGPoint {
        let paperW = PaperGeometry.designWidth
        let paperH = PaperGeometry.designHeight
        let overhangX = (paperW / 0.75 - paperW) / 2   // ≈ 80.62
        let overhangY = (paperH / 0.75 - paperH) / 2   // ≈ 113.81
        let minX = -overhangX
        let maxX = paperW + overhangX - addOn.size.width
        let minY = -overhangY
        let maxY = paperH + overhangY - addOn.size.height
        return CGPoint(
            x: min(max(minX, p.x), maxX),
            y: min(max(minY, p.y), maxY)
        )
    }

    private var pinchGesture: some Gesture {
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
    }

    private var twoFingerRotationGesture: some Gesture {
        RotationGesture()
            .onChanged { a in
                if !isSelected { onSelect() }
                spinDelta = a.radians
            }
            .onEnded { a in
                addOn.rotation += a.radians
                spinDelta = 0
            }
    }

    /// Bottom-right corner handle drag → uniform scale relative to the addon center.
    /// Aspect ratio is preserved.
    private var resizeGesture: some Gesture {
        DragGesture()
            .onChanged { v in
                if !isSelected { onSelect() }
                let halfW = Double(addOn.size.width * scale / 2)
                let halfH = Double(addOn.size.height * scale / 2)
                let theta = totalRotation
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
    }

    /// Bottom rotate chip drag → rotates the addon using atan2 from the addon center
    /// to the handle's current position. Uses global coordinates because the gesture
    /// lives inside a rotated parent and we need screen-space deltas.
    private var rotateHandleGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { v in
                if !isSelected { onSelect() }
                let handleDist = Double(outerHeight / 2 + chipSize / 2 + chipGap)
                let theta0 = addOn.rotation
                // Initial handle screen position relative to addon center.
                let initX = handleDist * Foundation.sin(theta0)
                let initY = handleDist * Foundation.cos(theta0)
                let dx = Double(v.location.x - v.startLocation.x)
                let dy = Double(v.location.y - v.startLocation.y)
                let curX = initX + dx
                let curY = initY + dy
                // atan2(x, y) here treats +y as the neutral (downward) direction,
                // which matches our convention for `addOn.rotation`.
                let newAngle = Foundation.atan2(curX, curY)
                var delta = newAngle - theta0
                if delta >  .pi { delta -= 2 * .pi }
                if delta < -.pi { delta += 2 * .pi }
                spinDelta = delta
            }
            .onEnded { _ in
                addOn.rotation += spinDelta
                spinDelta = 0
            }
    }
}
