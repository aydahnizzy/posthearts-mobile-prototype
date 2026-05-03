import SwiftUI
import UIKit

/// Loads an add-on image (emoji or sticker) by name. Falls through several
/// extensions because `UIImage(named:)` doesn't search for `.webp` on its own,
/// even though iOS 14+ decodes webp natively via Image I/O. Stickers in this
/// project are stored as `.webp` to keep the bundle small (~10 MB vs ~130 MB
/// when re-encoded as PNG).
@MainActor
func addOnImage(named name: String) -> UIImage? {
    if let img = UIImage(named: name) { return img }
    for ext in ["webp", "png", "jpg", "jpeg"] {
        if let url = Bundle.main.url(forResource: name, withExtension: ext),
           let data = try? Data(contentsOf: url),
           let img = UIImage(data: data) {
            return img
        }
    }
    return nil
}

/// SwiftUI helper that wraps `addOnImage(named:)` and returns an empty
/// placeholder if the asset can't be found, matching the existing call sites.
struct AddOnImage: View {
    let name: String

    var body: some View {
        Image(uiImage: addOnImage(named: name) ?? UIImage())
            .resizable()
    }
}
