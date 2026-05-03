import SwiftUI

/// Catalog of add-ons available in the picker. Asset names match the files in
/// `Resources/Emojis` (PNG) and `Resources/Stickers` (WebP), imported from the
/// Posthearts web app's `public/emojis` and `public/stickers` folders. Stickers
/// from packs other than `1-base` are namespaced via a pack prefix
/// (`iwd-`, `gabriel-`, `christmas-`, `valentines-`, `alphabet-`) to avoid
/// filename collisions in the flat resource bundle.
enum AddOnCatalog {
    static let emojis: [String] = [
        "aubergine", "balloon", "beach", "black-heart", "blue-heart",
        "brown-heart", "butterfly", "cake-slice", "celebrate", "cheers",
        "chocolate", "cover-mouth", "deep-purple-heart", "diamond-ring", "diamond",
        "dollar-cash", "fere", "fist-bump", "flower", "glass-blue-heart",
        "grey-heart", "heart-letter", "light-blue-heart", "lip-bite", "love-cat",
        "love-eyes", "love-hand", "monkey-shy", "moon", "pepper",
        "pink-heart-shimmer", "plum", "purple-heart", "radiating-heart", "red-flower",
        "red-heart", "rock", "rocket", "rose", "shimmer",
        "shine", "sunflower", "thunderbolt", "trophy", "two-heart",
        "water-drops", "white-heart", "withered-rose", "yellow-heart", "yellow-ish-heart",
    ]

    static let stickerPacks: [(name: String, items: [String])] = [
        (
            "Base",
            [
                "bff", "bikini", "donut", "fun-glasses", "fun-window",
                "good-vibes-2", "good-vibes-3", "greenhand", "heart-badge", "leaf",
                "lollipop", "love-till-70s", "love-yourself", "love", "oj",
                "okay", "palmtree", "pineapple", "share-your-love", "shine-like-a-diamond",
                "shooting-star-badge", "sun-hat", "sunflower-badge",
            ]
        ),
        (
            "Women",
            [
                "iwd-best-woman-ever", "iwd-female", "iwd-iwd", "iwd-just-a-girl", "iwd-you-ate",
            ]
        ),
        (
            "Love",
            [
                "gabriel-bathrobe", "gabriel-bride", "gabriel-burger", "gabriel-cake-2", "gabriel-cake-3",
                "gabriel-cake-4", "gabriel-cake-slice", "gabriel-cake", "gabriel-cherries", "gabriel-chocolate",
                "gabriel-couple-2", "gabriel-couple-3", "gabriel-couple-4", "gabriel-couple-5", "gabriel-couple-6",
                "gabriel-couple", "gabriel-cupcake", "gabriel-cupid-heart", "gabriel-cupid", "gabriel-devil-heart",
                "gabriel-diamond-ring-2", "gabriel-diamond-ring", "gabriel-diamond", "gabriel-earrings", "gabriel-engagement",
                "gabriel-giftbox-2", "gabriel-giftbox", "gabriel-heart-and-key", "gabriel-heart-cherries", "gabriel-heart-fingers",
                "gabriel-heel", "gabriel-love-2", "gabriel-love-3", "gabriel-love-4", "gabriel-love-5",
                "gabriel-love-6", "gabriel-love-balloon", "gabriel-love-balloons", "gabriel-love-calender", "gabriel-love-cloud",
                "gabriel-love-envelope", "gabriel-love-glasses", "gabriel-love-potion", "gabriel-newly-wed", "gabriel-purple-hearts",
                "gabriel-red-lips", "gabriel-slipper", "gabriel-strawberry", "gabriel-sweet", "gabriel-three-hearts",
            ]
        ),
        (
            "Christmas",
            [
                "christmas-2026-frame", "christmas-2026-gold", "christmas-2026-red", "christmas-baubles",
                "christmas-happy-holidays", "christmas-hny", "christmas-holly-berries", "christmas-i-love-you",
                "christmas-jingle-bells", "christmas-merry-christmas", "christmas-present", "christmas-ribbons",
                "christmas-seasons-greetings", "christmas-stick-candy", "christmas-tis-the-season", "christmas-tree-stars",
            ]
        ),
        (
            "Valentines",
            [
                "valentines-be-mine", "valentines-cubes", "valentines-green-love-stamp", "valentines-happy-valentines-day",
                "valentines-heart-sign", "valentines-i-love-you-2", "valentines-i-love-you", "valentines-locket",
                "valentines-love-plate", "valentines-love-sign", "valentines-love-songs", "valentines-love-stamp",
                "valentines-perfume", "valentines-red-love-stamp", "valentines-sending-you-love", "valentines-sent-with-love",
                "valentines-teddy-bears", "valentines-together-forever", "valentines-tulip-envelope", "valentines-twin-hearts",
                "valentines-two-wine-bottles", "valentines-wine-bottle", "valentines-xoxo",
            ]
        ),
        (
            "Alphabet",
            [
                "alphabet-a", "alphabet-b", "alphabet-c", "alphabet-d", "alphabet-e",
                "alphabet-f", "alphabet-g", "alphabet-h", "alphabet-i", "alphabet-j",
                "alphabet-k", "alphabet-l", "alphabet-m", "alphabet-n", "alphabet-o",
                "alphabet-p", "alphabet-q", "alphabet-r", "alphabet-s", "alphabet-t",
                "alphabet-u", "alphabet-v", "alphabet-w", "alphabet-x", "alphabet-y",
                "alphabet-z",
            ]
        ),
    ]

    /// Flat list of every sticker name across all packs.
    static let stickers: [String] = stickerPacks.flatMap(\.items)
}

struct AddOnPicker: View {
    @Bindable var letter: Letter
    var initialTab: Tab = .emoji
    @Environment(\.dismiss) private var dismiss
    @State private var tab: Tab
    @State private var stickerPackIndex: Int = 0

    init(letter: Letter, initialTab: Tab = .emoji) {
        self.letter = letter
        self.initialTab = initialTab
        self._tab = State(initialValue: initialTab)
    }

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

                if tab == .sticker {
                    stickerPackBar
                }

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(items, id: \.self) { name in
                            Button {
                                letter.addOns.append(
                                    AddOn.random(kind: tab == .emoji ? .emoji : .sticker, assetName: name)
                                )
                                dismiss()
                            } label: {
                                AddOnImage(name: name)
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

    private var stickerPackBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(AddOnCatalog.stickerPacks.enumerated()), id: \.offset) { idx, pack in
                    Button { stickerPackIndex = idx } label: {
                        Text(pack.name)
                            .font(.system(size: 14, weight: stickerPackIndex == idx ? .semibold : .regular))
                            .foregroundStyle(stickerPackIndex == idx ? Theme.Text.default : Theme.Text.secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(stickerPackIndex == idx ? Theme.Background.default : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }

    private var items: [String] {
        switch tab {
        case .emoji:
            return AddOnCatalog.emojis
        case .sticker:
            let safeIndex = min(max(0, stickerPackIndex), AddOnCatalog.stickerPacks.count - 1)
            return AddOnCatalog.stickerPacks[safeIndex].items
        }
    }
}
