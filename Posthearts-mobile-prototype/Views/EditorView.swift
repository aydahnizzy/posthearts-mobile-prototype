import SwiftUI

struct EditorView: View {
    @Bindable var letter: Letter
    @State private var selectedAddOnId: UUID? = nil
    @State private var sheet: SheetKind?

    enum SheetKind: String, Identifiable {
        case paper, font, color, addOn, alignment
        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                topBar

                LetterPreview(letter: letter, selectedAddOnId: $selectedAddOnId)
                    .aspectRatio(5.0/7.0, contentMode: .fit)
                    .padding(.horizontal, 16)

                bottomBar

                LetterInput(letter: letter)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .frame(maxHeight: .infinity)
            }
        }
        .sheet(item: $sheet) { kind in
            switch kind {
            case .paper:     PaperPicker(letter: letter).presentationDetents([.medium, .large])
            case .font:      FontPicker(letter: letter).presentationDetents([.medium, .large])
            case .color:     ColorPickerSheet(letter: letter).presentationDetents([.medium])
            case .addOn:     AddOnPicker(letter: letter).presentationDetents([.medium, .large])
            case .alignment: AlignmentSheet(letter: letter).presentationDetents([.height(220)])
            }
        }
    }

    private var topBar: some View {
        HStack {
            Text("Posthearts")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    private var bottomBar: some View {
        HStack(spacing: 8) {
            toolButton(icon: "doc.text", label: "Paper")  { sheet = .paper }
            toolButton(icon: "textformat", label: "Font") { sheet = .font }
            toolButton(icon: "paintpalette", label: "Color") { sheet = .color }
            toolButton(icon: "sparkles", label: "Add")   { sheet = .addOn }
            toolButton(icon: "align.vertical.center", label: "Align") { sheet = .alignment }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.horizontal, 16)
    }

    private func toolButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 18))
                Text(label).font(.system(size: 10))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(.primary)
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
                                    ? Color.accentColor.opacity(0.15)
                                    : Color.gray.opacity(0.08),
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
