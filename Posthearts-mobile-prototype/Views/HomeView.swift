import SwiftUI

struct HomeView: View {
    @Bindable var store: LettersStore
    let namespace: Namespace.ID
    let transitionVersion: Int
    let activeLetterId: UUID?
    @Binding var chromeVisible: Bool

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if store.letters.isEmpty {
                    emptyState
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                        .padding(.horizontal, 20)
                } else {
                    LazyVGrid(columns: columns, spacing: 32) {
                        ForEach(store.sortedByRecency) { letter in
                            ZStack {
                                // Decoy thumbnail. Hidden while this letter's editor is active
                                // so the user never sees a doubled render mid-transition;
                                // revealed instantly when the editor disappears, side-stepping
                                // iOS 18's source-hide leak on consecutive interactive dismisses.
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
                                .contextMenu {
                                    Button {
                                        store.duplicate(letter)
                                    } label: {
                                        Label("Duplicate", systemImage: "plus.square.on.square")
                                    }
                                    Button(role: .destructive) {
                                        store.delete(letter.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                } preview: {
                                    LetterPreview(
                                        letter: letter,
                                        selectedAddOnId: .constant(nil),
                                        interactive: false,
                                        frameCornerRadius: 16
                                    )
                                    .aspectRatio(850.0/1069.0, contentMode: .fit)
                                    .frame(width: 320)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 140)
            }
            .padding(.top, 64)
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { oldOffset, newOffset in
            // Always show chrome at the top of the feed.
            if newOffset <= 0 {
                if !chromeVisible { chromeVisible = true }
                return
            }
            let delta = newOffset - oldOffset
            if delta > 4 {
                if chromeVisible { chromeVisible = false }
            } else if delta < -4 {
                if !chromeVisible { chromeVisible = true }
            }
        }
        .overlay(alignment: .top) {
            topBar
                .opacity(chromeVisible ? 1 : 0)
                .offset(y: chromeVisible ? 0 : -120)
                .animation(.easeInOut(duration: 0.25), value: chromeVisible)
        }
        .background(Theme.Background.canvas)
    }

    // MARK: - Top bar

    private var topBar: some View {
        ZStack {
            // Centered logo, independent of side widths
            Image("posthearts-logo")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundStyle(Theme.Icon.brand)

            HStack {
                avatar
                Spacer()
                sortButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Theme.Background.canvas)
    }

    private var avatar: some View {
        Image("avatar")
            .resizable()
            .scaledToFill()
            .frame(width: 32, height: 32)
            .clipShape(Circle())
    }

    private var sortButton: some View {
        Button {
            // sort action
        } label: {
            Image("IconBlockSortDescending")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(Theme.Icon.hover)
        }
        .buttonStyle(.plain)
    }

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
