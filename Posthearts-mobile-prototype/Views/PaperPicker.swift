import SwiftUI

struct PaperPicker: View {
    @Bindable var letter: Letter
    @Environment(\.dismiss) private var dismiss
    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Paper.all) { paper in
                        Button { letter.paperId = paper.id } label: {
                            VStack(spacing: 6) {
                                Image(uiImage: UIImage(named: paper.id) ?? UIImage())
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(letter.paperId == paper.id ? Color.accentColor : .black.opacity(0.1), lineWidth: 2)
                                    )
                                Text(paper.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Paper")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
