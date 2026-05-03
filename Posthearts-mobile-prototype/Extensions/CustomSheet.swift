import SwiftUI

// MARK: - CustomSheet
//
// A bottom sheet that:
//   • dims/scales the page behind it (iOS-26-style "card" effect)
//   • has a grabber + optional leading button + title + close button header
//   • dismisses on a downward drag past 20% of screen height
//
// Usage:
//   .customSheet(isPresented: $showSheet, title: "Emoji") {
//       YourSheetContent()
//   }
//
//   // With a leading (e.g. undo) button:
//   .customSheet(isPresented: $showSheet, title: "Emoji", leading: {
//       Button(action: { ... }) { Image(systemName: "arrow.uturn.backward") }
//   }) {
//       YourSheetContent()
//   }

struct CustomSheet<SheetContent: View, LeadingButton: View>: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var progress: CGFloat
    let title: String
    let backdropColor: Color
    let sheetBackground: Color
    @ViewBuilder var leadingButton: () -> LeadingButton
    @ViewBuilder var sheetContent: () -> SheetContent

    @State private var dragY: CGFloat = 0

    func body(content: Content) -> some View {
        GeometryReader { geo in
            let dismissThreshold = geo.size.height * 0.2
            // 1.0 = fully open (no drag). 0.0 = at dismiss threshold.
            let openness: CGFloat = isPresented
                ? max(0, 1 - min(1, max(0, dragY) / dismissThreshold))
                : 0

            ZStack(alignment: .bottom) {
                // Backdrop fills the safe-area regions even when the sheet is
                // closed (so e.g. the status-bar zone matches the page chrome),
                // and is revealed behind the scaled-down page when open.
                backdropColor.ignoresSafeArea()

                // Page content: clipped, inset, and scaled while sheet is open.
                // When fully closed (openness == 0) we render `content` plain so
                // its inner views can keep extending into the safe area (e.g.
                // the editor's docked bottomSheet through the home-indicator
                // zone). The outer ZStack clip would otherwise cut them off.
                if openness > 0 {
                    content
                        .clipShape(RoundedRectangle(cornerRadius: 28 * openness))
                        .padding(.horizontal, 4 * openness)
                        .scaleEffect(1 - 0.06 * openness, anchor: .top)
                        .offset(y: 12 * openness)
                } else {
                    content
                }

                // The sheet itself
                SheetShell(
                    title: title,
                    dragY: $dragY,
                    dismissThreshold: dismissThreshold,
                    onDismiss: dismiss,
                    leadingButton: leadingButton,
                    content: sheetContent
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    // Background shape extends through both the home-indicator
                    // safe area AND the keyboard safe area, so the sheet's
                    // white fills behind the keyboard's translucent chrome
                    // (otherwise the pink backdrop would bleed through).
                    UnevenRoundedRectangle(
                        cornerRadii: .init(topLeading: 24, bottomLeading: 0, bottomTrailing: 0, topTrailing: 24),
                        style: .continuous
                    )
                    .fill(sheetBackground)
                    .ignoresSafeArea(.all, edges: .bottom)
                }
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -4)
                .padding(.top, 22)
                .ignoresSafeArea(.container, edges: .bottom)
                .offset(y: isPresented
                        ? max(0, dragY)
                        : geo.size.height + geo.safeAreaInsets.bottom)
                // Sheet rise/fall is intentionally snappier than the page-
                // behind reveal — value-scoped animation overrides whatever
                // `withAnimation` block is driving the rest of the transition.
                .animation(.smooth(duration: 0.25), value: isPresented)
                .allowsHitTesting(isPresented)
            }
            .onChange(of: openness) { _, newValue in
                progress = newValue
            }
            .onChange(of: isPresented) { _, _ in
                progress = openness
            }
        }
    }

    private func dismiss() {
        withAnimation(.smooth(duration: 0.4)) {
            isPresented = false
            dragY = 0
        }
    }
}

// MARK: - Sheet shell (grabber, title, close, drag-to-dismiss)

private struct SheetShell<Content: View, LeadingButton: View>: View {
    let title: String
    @Binding var dragY: CGFloat
    let dismissThreshold: CGFloat
    let onDismiss: () -> Void
    @ViewBuilder var leadingButton: () -> LeadingButton
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            // Header: grabber + leading + title + close. Drag gesture lives
            // here so the body content can still scroll/interact normally.
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 25, height: 4)
                    .padding(.top, 6)

                ZStack {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .kerning(0.3)
                        .foregroundStyle(Theme.Text.tertiary)

                    HStack {
                        leadingButton()
                        Spacer()
                        Button(action: onDismiss) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.Icon.hover)
                                .frame(width: 32, height: 32)
                                .background(Theme.Button.neutral, in: Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
            }
            .contentShape(Rectangle())
            .gesture(dragToDismissGesture)

            content()
        }
    }

    private var dragToDismissGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                var t = Transaction()
                t.disablesAnimations = true
                withTransaction(t) {
                    dragY = max(0, value.translation.height)
                }
            }
            .onEnded { _ in
                if dragY >= dismissThreshold {
                    onDismiss()
                } else {
                    withAnimation(.smooth(duration: 0.2)) {
                        dragY = 0
                    }
                }
            }
    }
}

// MARK: - View extension

extension View {
    func customSheet<Content: View, Leading: View>(
        isPresented: Binding<Bool>,
        progress: Binding<CGFloat> = .constant(0),
        title: String,
        backdropColor: Color = .accentColor,
        sheetBackground: Color = Color(.systemBackground),
        @ViewBuilder leading: @escaping () -> Leading = { EmptyView() },
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(CustomSheet(
            isPresented: isPresented,
            progress: progress,
            title: title,
            backdropColor: backdropColor,
            sheetBackground: sheetBackground,
            leadingButton: leading,
            sheetContent: content
        ))
    }
}
