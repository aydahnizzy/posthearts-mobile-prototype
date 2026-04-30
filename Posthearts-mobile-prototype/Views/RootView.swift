import SwiftUI

struct RootView: View {
    @State private var store = LettersStore()
    @State private var path: [Letter] = []
    @State private var tab: Tab = .home
    @State private var transitionVersion: Int = 0
    @State private var activeLetterId: UUID? = nil
    @Namespace private var letterNamespace

    enum Tab { case home, mailbox }

    var body: some View {
        NavigationStack(path: $path) {
            content
                .safeAreaInset(edge: .bottom, spacing: 0) { bottomNav }
                .navigationDestination(for: Letter.self) { letter in
                    EditorView(letter: letter)
                        .navigationTransition(.zoom(
                            sourceID: ZoomID(id: letter.id, version: transitionVersion),
                            in: letterNamespace
                        ))
                        .toolbar(.hidden, for: .navigationBar)
                        .onDisappear {
                            activeLetterId = nil
                            transitionVersion &+= 1
                        }
                }
        }
        .onChange(of: path) { _, newPath in
            if let letter = newPath.last {
                activeLetterId = letter.id
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .home:
            HomeView(
                store: store,
                namespace: letterNamespace,
                transitionVersion: transitionVersion,
                activeLetterId: activeLetterId
            )
        case .mailbox:
            MailboxView()
        }
    }

    // MARK: - Bottom nav

    private var bottomNav: some View {
        HStack(alignment: .bottom, spacing: 8) {
            navItem(
                icon: { iconImage("posthearts-logo", size: 28, tint: tab == .home ? Theme.Icon.hover : Theme.Icon.primary) },
                label: "Posthearts",
                isActive: tab == .home
            ) { tab = .home }

            navItem(
                icon: { iconImage("circle-plus", size: 36, tint: Theme.Icon.primary) },
                label: "New",
                isActive: false
            ) {
                let letter = store.create()
                path.append(letter)
            }

            navItem(
                icon: { iconImage("IconMailbox", size: 28, tint: tab == .mailbox ? Theme.Icon.hover : Theme.Icon.primary) },
                label: "Mailbox",
                isActive: tab == .mailbox
            ) { tab = .mailbox }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(Theme.Background.canvas)
    }

    private func navItem<Icon: View>(
        @ViewBuilder icon: () -> Icon,
        label: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                icon()
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .tracking(0.1)
                    .foregroundStyle(isActive ? Theme.Text.default : Theme.Text.tertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func iconImage(_ name: String, size: CGFloat, tint: Color) -> some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(tint)
    }
}

/// Composite id for the matched zoom transition. Bumping `version` after each
/// dismiss makes the next push use a fresh id, working around an iOS 18 bug
/// where the system's source-hide state leaks across consecutive interactive
/// dismisses of the same letter.
struct ZoomID: Hashable {
    let id: UUID
    let version: Int
}

#Preview {
    RootView()
}
