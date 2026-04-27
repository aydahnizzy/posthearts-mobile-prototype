import SwiftUI

struct ColorPickerSheet: View {
    @Bindable var letter: Letter
    @Environment(\.dismiss) private var dismiss
    private let columns = [GridItem(.adaptive(minimum: 60), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(FrameColor.all) { c in
                        Button { letter.frameColor = c } label: {
                            Circle()
                                .fill(c.color)
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            letter.frameColor == c ? .white : .clear,
                                            lineWidth: 3
                                        )
                                        .padding(4)
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(.black.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
