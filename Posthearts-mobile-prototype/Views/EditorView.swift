import SwiftUI

struct EditorView: View {
    @Bindable var letter: Letter
    @Environment(\.dismiss) private var dismiss

    @State private var selectedAddOnId: UUID? = nil
    @State private var sheet: SheetKind?
    @State private var showColorPopover: Bool = false
    @State private var sheetExpanded: Bool = false
    @State private var composing: Bool = false
    @GestureState private var dragOffset: CGFloat = 0
    @FocusState private var inputFocused: Bool

    private let compactSheetHeight: CGFloat = 150
    private let expandedSheetHeight: CGFloat = 560
    private let popoverSpring: Animation = .spring(response: 0.4, dampingFraction: 0.6)

    enum SheetKind: String, Identifiable {
        case font, size, align, stickers
        var id: String { rawValue }
    }

    private var resolvedSheetHeight: CGFloat {
        let base = sheetExpanded ? expandedSheetHeight : compactSheetHeight
        let proposed = base - dragOffset
        return min(max(compactSheetHeight, proposed), expandedSheetHeight)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            letter.frameColor.color
                .ignoresSafeArea()

            GeometryReader { geo in
                VStack(spacing: 0) {
                    LetterPreview(letter: letter, selectedAddOnId: $selectedAddOnId)
                        .frame(
                            width: geo.size.width,
                            height: geo.size.width / PaperGeometry.aspect
                        )
                    Spacer(minLength: 0)
                }
                .padding(.top, 60)
            }

            if composing {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { inputFocused = false }
                    .transition(.opacity)

                composeCardLayer
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                bottomSheet
                    .transition(.opacity)
            }

            if showColorPopover && !composing {
                colorPopover
                    .padding(.bottom, resolvedSheetHeight + 12)
                    .padding(.horizontal, 20)
                    .transition(.scale(scale: 0.8, anchor: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }

            VStack(spacing: 0) {
                topActionBar
                Spacer()
            }
        }
        .onChange(of: inputFocused) { _, isFocused in
            if !isFocused {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    composing = false
                }
            }
        }
        .sheet(item: $sheet) { kind in
            switch kind {
            case .font:     FontPicker(letter: letter).presentationDetents([.medium, .large])
            case .size:     FontSizeSheet(letter: letter).presentationDetents([.height(220)])
            case .align:    AlignmentSheet(letter: letter).presentationDetents([.height(220)])
            case .stickers: AddOnPicker(letter: letter).presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - Color popover

    private var colorPopover: some View {
        let visible = Array(FrameColor.all.prefix(7))
        return HStack(spacing: 10) {
            ForEach(Array(visible.enumerated()), id: \.element.id) { idx, color in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        letter.frameColor = color
                    }
                } label: {
                    Circle()
                        .fill(color.color)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .strokeBorder(.white, lineWidth: letter.frameColor == color ? 3 : 0)
                                .padding(2)
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(.black.opacity(0.1), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Theme.Background.onCanvas, in: Capsule())
        .shadow(color: Color(hex: 0x2A2A2A, alpha: 0.15), radius: 12, x: 0, y: 4)
    }

    // MARK: - Top action bar

    private var topActionBar: some View {
        HStack(spacing: 8) {
            iconButton(bg: Color.black.opacity(0.5)) {
                dismiss()
            } content: {
                Image("chevron-left-small")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.white)
            }

            Spacer()

            HStack(spacing: 0) {
                pillIcon("arrow-down") { /* download */ }
                pillIcon("three-dots") { /* more */ }
            }
            .padding(.horizontal, 4)
            .frame(height: 40)
            .background(Color.black.opacity(0.5), in: Capsule())

            iconButton(bg: Theme.Background.onCanvas) {
                // send action
            } content: {
                Image("IconPaperPlaneTopRight")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Theme.Icon.hover)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func iconButton<Content: View>(
        bg: Color,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        Button(action: action) {
            content()
                .frame(width: 40, height: 40)
                .background(bg, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private func pillIcon(_ name: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(name)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom sheet

    private var bottomSheet: some View {
        VStack(spacing: 20) {
            dragHandle

            toolBar

            inputBar

            Spacer(minLength: 0)
        }
        .padding(.top, 8)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .frame(height: resolvedSheetHeight, alignment: .top)
        .background {
            UnevenRoundedRectangle(
                cornerRadii: .init(topLeading: 20, bottomLeading: 0, bottomTrailing: 0, topTrailing: 20),
                style: .continuous
            )
            .fill(Theme.Background.onCanvas)
            .shadow(color: Color(hex: 0x2A2A2A, alpha: 0.10), radius: 8, x: 0, y: -4)
            .ignoresSafeArea(edges: .bottom)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: sheetExpanded)
    }

    private var dragHandle: some View {
        Capsule()
            .fill(Color(hex: 0xD9D9D9))
            .frame(width: 40, height: 3)
            .padding(.vertical, 0)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .gesture(sheetDragGesture)
    }

    private var sheetDragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                let base: CGFloat = sheetExpanded ? expandedSheetHeight : compactSheetHeight
                let predicted = base - value.predictedEndTranslation.height
                let midpoint = (compactSheetHeight + expandedSheetHeight) / 2
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    sheetExpanded = predicted > midpoint
                }
            }
    }

private var toolBar: some View {
        HStack(spacing: 0) {
            toolItem(label: "Font") { sheet = .font } icon: {
                Image("IconText1")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Theme.Icon.hover)
            }

            Spacer(minLength: 0)

            toolItem(label: "Size") { sheet = .size } icon: {
                Text("\(letter.fontSizeStep)x")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.Icon.hover)
                    .frame(width: 24, height: 24)
            }

            Spacer(minLength: 0)

            toolItem(label: "Align") { sheet = .align } icon: {
                Image("aligned-top")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Theme.Icon.hover)
            }

            Spacer(minLength: 0)

            toolItem(label: "Color") {
                withAnimation(popoverSpring) { showColorPopover.toggle() }
            } icon: {
                Circle()
                    .fill(letter.frameColor.color)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .strokeBorder(.black.opacity(0.15), lineWidth: 2)
                    )
            }

            Spacer(minLength: 0)

            toolItem(label: "Stickers") { sheet = .stickers } icon: {
                Image("stickers")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
            }
        }
    }

    private func toolItem<Icon: View>(
        label: String,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                icon()
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .tracking(0.1)
                    .foregroundStyle(Theme.Text.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var inputBar: some View {
        HStack(spacing: 4) {
            ZStack(alignment: .leading) {
                if letter.content.isEmpty {
                    Text("Express how you feel...")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.Text.secondary)
                        .allowsHitTesting(false)
                } else {
                    Text(letter.content)
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.Text.default)
                        .lineLimit(1)
                        .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
            .padding(.vertical, 8)

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
            .padding(.trailing, 4)
        }
        .frame(minHeight: 40)
        .background(Theme.Background.default, in: Capsule())
        .contentShape(Capsule())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                composing = true
            }
        }
    }

    private var composeCardLayer: some View {
        ComposeCard(
            letter: letter,
            focused: $inputFocused,
            onClear: {
                letter.content = ""
            },
            onSubmit: {
                inputFocused = false
            }
        )
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
        .task {
            try? await Task.sleep(for: .milliseconds(50))
            inputFocused = true
        }
    }
}

struct AlignmentSheet: View {
    @Bindable var letter: Letter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    ForEach(ContentAlignment.allCases) { a in
                        Button { letter.contentAlignment = a } label: {
                            VStack(spacing: 6) {
                                Image(systemName: icon(for: a))
                                    .font(.title2)
                                Text(a.label).font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                letter.contentAlignment == a
                                    ? Theme.Button.primary.opacity(0.15)
                                    : Theme.Background.default,
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Alignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func icon(for a: ContentAlignment) -> String {
        switch a {
        case .top: return "arrow.up.to.line"
        case .center: return "arrow.up.and.down"
        case .bottom: return "arrow.down.to.line"
        }
    }
}

#Preview {
    EditorView(letter: Letter())
}
