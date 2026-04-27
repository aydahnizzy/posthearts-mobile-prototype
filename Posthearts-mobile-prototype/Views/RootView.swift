import SwiftUI

struct RootView: View {
    @State private var store = LettersStore()
    @State private var path: [Letter] = []
    @State private var tab: Tab = .home

    enum Tab { case home, mailbox }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                content

                customTabBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
            .navigationDestination(for: Letter.self) { letter in
                EditorView(letter: letter)
                    .navigationBarBackButtonHidden(false)
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .onDisappear { store.touch(letter) }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .home:
            HomeView(store: store) { letter in path.append(letter) }
        case .mailbox:
            MailboxView()
        }
    }

    // MARK: - Custom tab bar

    private var customTabBar: some View {
        HStack(alignment: .center, spacing: 0) {
            tabButton(label: "Posthearts", isActive: tab == .home) {
                postheartsLogo(active: tab == .home)
            } action: {
                tab = .home
            }

            newButton

            tabButton(label: "Mailbox", isActive: tab == .mailbox) {
                Image(systemName: "tray.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(tab == .mailbox ? .primary : .secondary)
            } action: {
                tab = .mailbox
            }
        }
        .padding(.vertical, 10)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    private func tabButton<Icon: View>(
        label: String,
        isActive: Bool,
        @ViewBuilder icon: () -> Icon,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                icon()
                Text(label)
                    .font(.system(size: 11, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var newButton: some View {
        Button {
            let letter = store.create()
            path.append(letter)
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.7))
                        .frame(width: 44, height: 44)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Text("New")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func postheartsLogo(active: Bool) -> some View {
        // Simple wordmark-style glyph: two circles forming an infinity/heart cue.
        HStack(spacing: -6) {
            Circle()
                .strokeBorder(active ? Color.primary : Color.secondary, lineWidth: 3)
                .frame(width: 18, height: 18)
            Circle()
                .strokeBorder(active ? Color.primary : Color.secondary, lineWidth: 3)
                .frame(width: 18, height: 18)
        }
        .frame(height: 22)
    }
}

#Preview {
    RootView()
}
