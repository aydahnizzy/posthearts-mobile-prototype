import SwiftUI

struct EditorView: View {
    @Bindable var letter: Letter
    @Environment(\.dismiss) private var dismiss

    @State private var selectedAddOnId: UUID? = nil
    @State private var sheet: SheetKind?
    @State private var showColorPopover: Bool = false
    @State private var sheetExpanded: Bool = false
    @State private var composing: Bool = false
    @State private var sheetProgress: CGFloat = 0
    @State private var isRecordingVoice: Bool = false
    @State private var streamingTranscript: String?
    @GestureState private var dragOffset: CGFloat = 0
    @FocusState private var inputFocused: Bool

    private let compactSheetHeight: CGFloat = 150
    private let expandedSheetHeight: CGFloat = 560
    private let popoverSpring: Animation = .spring(response: 0.4, dampingFraction: 0.6)
    private let sheetTransition: Animation = .smooth(duration: 0.4)

    enum SheetKind: String, Identifiable {
        case font, align, paper, emoji, stickers, photo
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

            // White overlay scales with the sheet's openness — it's at full
            // opacity when the sheet is fully open and fades back to reveal
            // the frameColor as the user drags the sheet down.
            Color.white
                .ignoresSafeArea()
                .opacity(sheetProgress)

            // Editor chrome — fades out when the compose sheet opens so only
            // the white card + sheet are visible while typing.
            Group {
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

                bottomSheet

                if showColorPopover {
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
            // Editor chrome opacity is the inverse of sheet openness — content
            // re-emerges as the user drags the sheet down toward dismissal.
            .opacity(1 - sheetProgress)
        }
        .customSheet(
            isPresented: $composing,
            progress: $sheetProgress,
            title: "Express how you feel",
            backdropColor: letter.frameColor.color,
            sheetBackground: Theme.Background.onCanvas,
            leading: { undoButton }
        ) {
            composeSheetContent
        }
        .onChange(of: composing) { _, isComposing in
            if isComposing {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(150))
                    // Re-check at fire time: if a streaming reveal is in
                    // progress, defer focus until the reveal completes
                    // (handled in StreamingTranscriptText.onComplete).
                    guard streamingTranscript == nil else { return }
                    inputFocused = true
                }
            } else {
                inputFocused = false
                streamingTranscript = nil
            }
        }
        .onChange(of: inputFocused) { _, isFocused in
            if !isFocused && composing {
                withAnimation(sheetTransition) {
                    composing = false
                }
            }
        }
        .sheet(item: $sheet) { kind in
            switch kind {
            case .font:     FontPicker(letter: letter).presentationDetents([.medium, .large])
            case .align:    AlignmentSheet(letter: letter).presentationDetents([.height(220)])
            case .paper:    PaperPicker(letter: letter).presentationDetents([.medium, .large])
            case .emoji:    AddOnPicker(letter: letter, initialTab: .emoji).presentationDetents([.medium, .large])
            case .stickers: AddOnPicker(letter: letter, initialTab: .sticker).presentationDetents([.medium, .large])
            case .photo:    PhotosPlaceholderSheet().presentationDetents([.medium])
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: letter.frameColor)
        .sensoryFeedback(.impact(weight: .medium), trigger: sheetExpanded)
        .sensoryFeedback(.impact(weight: .light), trigger: composing)
        .sensoryFeedback(.selection, trigger: showColorPopover)
    }

    // MARK: - Color popover

    private var colorPopover: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FrameColor.all) { color in
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
                                    .strokeBorder(.black.opacity(0.5), lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .background(Theme.Background.onCanvas, in: Capsule())
        .shadow(color: Color(hex: 0x2A2A2A, alpha: 0.15), radius: 12, x: 0, y: 4)
    }

    // MARK: - Top action bar

    private var topActionBar: some View {
        HStack(spacing: 8) {
            iconButton(bg: Color.black.opacity(0.5)) {
                dismiss()
            } content: {
                Image("IconChevronLeftMedium")
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
                Haptics.notify(.success)
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

            inputBar

            toolBar

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
        .ignoresSafeArea(.container, edges: .bottom)
        .animation(.smooth(duration: 0.25), value: sheetExpanded)
    }

    private var dragHandle: some View {
        Capsule()
            .fill(Color(hex: 0xD9D9D9))
            .frame(width: 40, height: 3)
            .opacity(0)
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
                withAnimation(.smooth(duration: 0.25)) {
                    sheetExpanded = predicted > midpoint
                }
            }
    }

    private var undoButton: some View {
        Button {
            // undo action — wired up later
        } label: {
            Image(systemName: "arrow.uturn.backward")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.Icon.hover)
                .frame(width: 32, height: 32)
                .background(Theme.Button.neutral, in: Circle())
        }
        .buttonStyle(.plain)
    }

private var toolBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                toolItem(label: "Font") { sheet = .font } icon: {
                    Image("IconText1")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Theme.Icon.hover)
                }

                toolItem(label: "Align") { sheet = .align } icon: {
                    Image("IconAlignmentLeft")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Theme.Icon.hover)
                }

                toolItem(label: "Color") {
                    withAnimation(popoverSpring) { showColorPopover.toggle() }
                } icon: {
                    ZStack {
                        Circle()
                            .fill(letter.frameColor.color)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .strokeBorder(.black.opacity(0.3), lineWidth: 2)
                            )
                    }
                    .frame(width: 24, height: 24)
                }

                toolItem(label: "Paper") { sheet = .paper } icon: {
                    oversizedIcon("Icon-button-2", size: 48)
                }

                toolItem(label: "Emoji") { sheet = .emoji } icon: {
                    oversizedIcon("Icon-button-3", size: 72)
                }

                toolItem(label: "Stickers") { sheet = .stickers } icon: {
                    oversizedIcon("Icon-button-1", size: 72)
                }

                toolItem(label: "Photos") { sheet = .photo } icon: {
                    oversizedIcon("Icon-button", size: 72)
                }
            }
        }
        .scrollClipDisabled()
    }

    /// Oversized PNG icons (Paper / Emoji / Stickers / Photos). The image
    /// renders at `size` for visual weight but the layout slot stays 24pt so
    /// it lines up with the other 24pt template icons in the toolbar.
    private func oversizedIcon(_ name: String, size: CGFloat) -> some View {
        ZStack {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
        .frame(width: 24, height: 24)
    }

    private func toolItem<Icon: View>(
        label: String,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
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

    @ViewBuilder
    private var inputBar: some View {
        if isRecordingVoice {
            VoiceRecorderBar(
                letter: letter,
                isActive: $isRecordingVoice,
                onTranscriptReady: { transcript in
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(350))
                        streamingTranscript = transcript
                        withAnimation(sheetTransition) {
                            composing = true
                        }
                    }
                }
            )
                .transition(.opacity)
        } else {
            regularInputBar
                .transition(.opacity)
        }
    }

    private var regularInputBar: some View {
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
            .padding(.trailing, letter.content.isEmpty ? 0 : 16)
            .padding(.vertical, 8)

            if letter.content.isEmpty {
                Button {
                    withAnimation(.smooth(duration: 0.25)) {
                        isRecordingVoice = true
                    }
                    Haptics.impact(.light)
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
        }
        .frame(minHeight: 40)
        .background(Capsule().fill(Theme.Background.default))
        .contentShape(Capsule())
        .onTapGesture {
            withAnimation(sheetTransition) {
                composing = true
            }
        }
    }

    /// Body of the compose CustomSheet — multiline TextField + a floating
    /// trash button at the bottom-right when there's content. The keyboard is
    /// auto-shown via the `composing` change handler on the EditorView body.
    private var composeSheetContent: some View {
        ZStack(alignment: .bottomTrailing) {
            // TextEditor scrolls internally and keeps the cursor visible
            // above the keyboard automatically, so it doesn't fight a parent
            // ScrollView's gestures the way TextField(axis: .vertical) did.
            TextEditor(text: $letter.content)
                .focused($inputFocused)
                .font(.system(size: 16))
                .lineSpacing(5)
                .foregroundStyle(Theme.Text.default)
                .tint(Theme.Text.default)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .opacity(streamingTranscript == nil ? 1 : 0)
                .disabled(streamingTranscript != nil)

            if let streaming = streamingTranscript {
                StreamingTranscriptText(
                    text: streaming,
                    onComplete: {
                        letter.content = streaming
                        streamingTranscript = nil
                        Task { @MainActor in
                            try? await Task.sleep(for: .milliseconds(50))
                            inputFocused = true
                        }
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }

            if !letter.content.isEmpty && streamingTranscript == nil {
                Button {
                    letter.content = ""
                    Haptics.impact(.medium)
                } label: {
                    Image("trash-can")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Theme.Icon.hover)
                        .frame(width: 32, height: 32)
                        .background(Theme.Background.onCanvas, in: Circle())
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 0)
                }
                .buttonStyle(.plain)
                .padding(16)
            }
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
