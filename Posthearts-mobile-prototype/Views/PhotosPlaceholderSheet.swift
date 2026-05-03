import SwiftUI

/// Placeholder for the "Photos" toolbar tool. The full photo-pick + crop flow
/// isn't built yet — for now this just acknowledges the tap.
struct PhotosPlaceholderSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(Theme.Text.tertiary)
                Text("Photos")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.Text.default)
                Text("Picking and pinning photos to your letter is coming soon.")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.Text.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
