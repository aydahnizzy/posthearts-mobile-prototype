import SwiftUI

struct MailboxView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(.secondary)
            Text("Mailbox")
                .font(.system(size: 22, weight: .bold))
            Text("Letters you've received and shared\nwill show up here.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
