import SwiftUI

struct RootView: View {
    @State private var store = LettersStore()
    @State private var path: [Letter] = []
    @State private var tab: Tab = .home
    @State private var transitionVersion: Int = 0
    @State private var activeLetterId: UUID? = nil
    @State private var chromeVisible: Bool = true
    @Namespace private var letterNamespace
    @Environment(\.scenePhase) private var scenePhase

    enum Tab { case home, mailbox }

    var body: some View {
        NavigationStack(path: $path) {
            content
                .overlay(alignment: .bottom) {
                    bottomNav
                        .opacity(chromeVisible ? 1 : 0)
                        .offset(y: chromeVisible ? 0 : 120)
                        .animation(.easeInOut(duration: 0.25), value: chromeVisible)
                }
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
        .sensoryFeedback(.selection, trigger: tab)
        .sensoryFeedback(.impact(weight: .light), trigger: path.count)
        .onChange(of: scenePhase) { _, phase in
            // Force a synchronous save before the app suspends so a Stop
            // from Xcode (or backgrounding) can't drop pending edits.
            if phase != .active {
                store.save()
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
                activeLetterId: activeLetterId,
                chromeVisible: $chromeVisible
            )
        case .mailbox:
            MailboxView()
        }
    }

    // MARK: - Bottom nav

    private var bottomNav: some View {
        HStack(spacing: 8) {
            navIconButton(isActive: tab == .home) {
                Image("IconHomeRoundDoor")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(tab == .home ? Theme.Icon.hover : Theme.Icon.secondary)
            } action: { tab = .home }

            navIconButton(isActive: false) {
                Image("circle-plus")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(Theme.Icon.secondary)
            } action: {
                let letter = store.create()
                path.append(letter)
            }

            navIconButton(isActive: tab == .mailbox) {
                Image("IconMailbox")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(tab == .mailbox ? Theme.Icon.hover : Theme.Icon.secondary)
            } action: { tab = .mailbox }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 0)
        .background(Theme.Background.canvas)
    }

    private func navIconButton<Content: View>(
        isActive: Bool,
        @ViewBuilder icon: () -> Content,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            icon()
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
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
