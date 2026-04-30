import SwiftUI

struct HomeView: View {
    @Bindable var store: LettersStore
    let namespace: Namespace.ID
    let transitionVersion: Int
    let activeLetterId: UUID?

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    if store.letters.isEmpty {
                        emptyState
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                            .padding(.horizontal, 20)
                    } else {
                        ForEach(store.grouped) { group in
                            VStack(alignment: .leading, spacing: 16) {
                                Text(group.label)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Theme.Text.default)

                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(group.letters) { letter in
                                        ZStack {
                                            // Decoy thumbnail. Hidden while this letter's editor is active
                                            // (push → open → dismiss anim) so the user never sees a doubled
                                            // render mid-transition; revealed instantly the moment the editor
                                            // disappears, which side-steps iOS 18's source-hide leak bug.
                                            LetterThumbnail(letter: letter)
                                                .opacity(activeLetterId == letter.id ? 0 : 1)
                                                .animation(nil, value: activeLetterId)
                                                .allowsHitTesting(false)

                                            NavigationLink(value: letter) {
                                                LetterThumbnail(letter: letter)
                                            }
                                            .buttonStyle(PressableScaleStyle())
                                            .matchedTransitionSource(
                                                id: ZoomID(id: letter.id, version: transitionVersion),
                                                in: namespace
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    Spacer(minLength: 140)
                }
                .padding(.top, 24)
            }
            .safeAreaInset(edge: .top, spacing: 0) { topBar }
        }
        .background(Theme.Background.canvas)
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            avatar
            Spacer()
            proPill
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(Theme.Background.canvas)
    }

    private var avatar: some View {
        Image("avatar")
            .resizable()
            .scaledToFill()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
    }

    private var proPill: some View {
        HStack(spacing: 6) {
            Image("diamond")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
            Text("Pro")
                .font(.system(size: 12, weight: .medium))
                .tracking(0.1)
        }
        .foregroundStyle(Theme.Text.onPrimary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            LinearGradient(
                colors: [Color(hex: 0xFC4EB7), Color(hex: 0x5C59ED)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: Capsule()
        )
    }

//    // MARK: - Floating search
//
//    private var floatingSearch: some View {
//        Button {
//            // search action — wired up later
//        } label: {
//            Image("magnifying-glass")
//                .renderingMode(.template)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 16, height: 16)
//                .foregroundStyle(Theme.Icon.primary)
//                .frame(width: 40, height: 28)
//                .background(Theme.Background.onCanvas, in: Capsule())
//                .shadow(color: Color(hex: 0x595959, alpha: 0.2), radius: 8, x: 0, y: 0)
//        }
//        .buttonStyle(.plain)
//    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "envelope.open")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Theme.Text.tertiary)
            Text("No letters yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.Text.default)
            Text("Tap + below to write your first letter.")
                .font(.system(size: 14))
                .foregroundStyle(Theme.Text.secondary)
        }
    }
}
