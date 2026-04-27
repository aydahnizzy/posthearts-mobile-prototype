import SwiftUI

struct HomeView: View {
    @Bindable var store: LettersStore
    let onOpen: (Letter) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                if store.letters.isEmpty {
                    emptyState
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                        .padding(.horizontal, 20)
                } else {
                    ForEach(store.grouped) { group in
                        VStack(alignment: .leading, spacing: 14) {
                            Text(group.label)
                                .font(.system(size: 22, weight: .bold))
                                .padding(.horizontal, 20)

                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(group.letters) { letter in
                                    LetterThumbnail(letter: letter) { onOpen(letter) }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }

                Spacer(minLength: 100)   // breathing room above tab bar
            }
        }
        .background(Color(.systemBackground))
    }

    private var topBar: some View {
        HStack {
            Circle()
                .fill(LinearGradient(
                    colors: [Color(h: 320, s: 100, l: 84), Color(h: 241, s: 80, l: 64)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(.white.opacity(0.85))
                        .font(.system(size: 16))
                )
            Spacer()
            proPill
        }
    }

    private var proPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "diamond.fill")
                .font(.system(size: 12, weight: .bold))
            Text("Pro")
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [Color(h: 289, s: 87, l: 63), Color(h: 241, s: 80, l: 64)],
                startPoint: .leading, endPoint: .trailing
            ),
            in: Capsule()
        )
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "envelope.open")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.secondary)
            Text("No letters yet")
                .font(.system(size: 18, weight: .semibold))
            Text("Tap + below to write your first letter.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
    }
}
