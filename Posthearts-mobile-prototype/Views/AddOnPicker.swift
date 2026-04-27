import SwiftUI

/// Catalog of add-ons available in the picker. Asset names must match files in the bundle.
enum AddOnCatalog {
    static let emojis: [String] = [
        "red-heart", "radiating-heart", "purple-heart",
        "love-eyes", "diamond-ring", "balloon",
        "butterfly", "flower", "rose", "sunflower",
    ]
    static let stickers: [String] = [
        "donut", "lollipop", "palmtree", "pineapple",
        "sun-hat", "sunflower-badge",
    ]
}

struct AddOnPicker: View {
    @Bindable var letter: Letter
    @Environment(\.dismiss) private var dismiss
    @State private var tab: Tab = .emoji

    enum Tab: String, CaseIterable, Identifiable {
        case emoji = "Emojis", sticker = "Stickers"
        var id: String { rawValue }
    }

    private let columns = [GridItem(.adaptive(minimum: 72), spacing: 12)]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $tab) {
                    ForEach(Tab.allCases) { t in Text(t.rawValue).tag(t) }
                }
                .pickerStyle(.segmented)
                .padding()

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(items, id: \.self) { name in
                            Button {
                                letter.addOns.append(
                                    AddOn.random(kind: tab == .emoji ? .emoji : .sticker, assetName: name)
                                )
                                dismiss()
                            } label: {
                                Image(uiImage: UIImage(named: name) ?? UIImage())
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 64, height: 64)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add-Ons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var items: [String] {
        tab == .emoji ? AddOnCatalog.emojis : AddOnCatalog.stickers
    }
}
