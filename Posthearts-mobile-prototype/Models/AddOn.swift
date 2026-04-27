import Foundation
import CoreGraphics

enum AddOnKind: String, Codable {
    case sticker, emoji, photo
}

struct AddOn: Identifiable, Equatable {
    let id = UUID()
    let kind: AddOnKind
    /// Asset name in the bundle (without extension).
    let assetName: String
    /// Position in original-paper coordinates (483.73 × 682.85).
    var position: CGPoint
    /// Size in original-paper units. Default ~120 for stickers/emojis.
    var size: CGSize
    /// Rotation in radians.
    var rotation: Double

    static func random(kind: AddOnKind, assetName: String, defaultSize: CGFloat = 120) -> AddOn {
        // Match web defaults: positions span the paper edges so add-ons hang off the corners.
        let candidates: [CGPoint] = [
            CGPoint(x: -22.630675836930457, y: 623.2240437170263),
            CGPoint(x: 417.9183594964029,   y: 630.162147146283),
            CGPoint(x: -15.221022659472423, y: -16.431391681055157),
            CGPoint(x: 434.1749355635492,   y: -23.185283302158272),
            CGPoint(x: 168.0213534532374,   y: 218.86984462829736),
            CGPoint(x: 182.19104637889689,  y: 573.7188603117506),
        ]
        return AddOn(
            kind: kind,
            assetName: assetName,
            position: candidates.randomElement() ?? .init(x: 180, y: 280),
            size: CGSize(width: defaultSize, height: defaultSize),
            rotation: Double.random(in: -0.15...0.15)
        )
    }
}
