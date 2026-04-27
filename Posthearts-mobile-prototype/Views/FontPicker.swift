import SwiftUI

struct FontPicker: View {
    @Bindable var letter: Letter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                List(PostFont.all) { font in
                    Button {
                        letter.fontId = font.id
                    } label: {
                        HStack {
                            Text("Forever yours")
                                .font(font.swiftUIFont())
                            Spacer()
                            Text(font.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if letter.fontId == font.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Size")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        Text("A").font(.caption)
                        Slider(
                            value: Binding(
                                get: { Double(letter.fontSizeStep) },
                                set: { letter.fontSizeStep = Int($0.rounded()) }
                            ),
                            in: 1...5,
                            step: 1
                        )
                        Text("A").font(.title2)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Font")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
