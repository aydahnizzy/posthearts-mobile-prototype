import SwiftUI

struct FontSizeSheet: View {
    @Bindable var letter: Letter
    @Environment(\.dismiss) private var dismiss

    private let steps = Array(1...5)

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    ForEach(steps, id: \.self) { step in
                        Button { letter.fontSizeStep = step } label: {
                            Text("\(step)x")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(
                                    letter.fontSizeStep == step
                                        ? Theme.Text.onPrimary
                                        : Theme.Text.default
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    letter.fontSizeStep == step
                                        ? Theme.Button.primary
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
            .navigationTitle("Size")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
