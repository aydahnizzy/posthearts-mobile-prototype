import SwiftUI
import UIKit

/// A blur view whose opacity fades along an edge — opaque at the anchor edge,
/// transparent at the opposite edge. iOS 17 has no public variable-blur API, so
/// this approximates the effect with a single `UIVisualEffectView` masked by a
/// linear gradient. Use `.topToBottom` for top bars and `.bottomToTop` for
/// bottom bars.
struct ProgressiveBlur: UIViewRepresentable {
    enum Direction { case topToBottom, bottomToTop }

    var direction: Direction = .topToBottom
    var style: UIBlurEffect.Style = .systemUltraThinMaterial

    func makeUIView(context: Context) -> ProgressiveBlurView {
        let v = ProgressiveBlurView()
        v.style = style
        v.direction = direction
        return v
    }

    func updateUIView(_ view: ProgressiveBlurView, context: Context) {
        view.style = style
        view.direction = direction
    }
}

final class ProgressiveBlurView: UIView {
    private let blurView = UIVisualEffectView()
    private let maskLayer = CAGradientLayer()

    var direction: ProgressiveBlur.Direction = .topToBottom {
        didSet { applyDirection() }
    }

    var style: UIBlurEffect.Style = .systemUltraThinMaterial {
        didSet { blurView.effect = UIBlurEffect(style: style) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        addSubview(blurView)
        blurView.effect = UIBlurEffect(style: style)
        maskLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        maskLayer.locations = [0.0, 1.0]
        blurView.layer.mask = maskLayer
        applyDirection()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        maskLayer.frame = bounds
        CATransaction.commit()
    }

    private func applyDirection() {
        switch direction {
        case .topToBottom:
            maskLayer.startPoint = CGPoint(x: 0.5, y: 0)
            maskLayer.endPoint = CGPoint(x: 0.5, y: 1)
        case .bottomToTop:
            maskLayer.startPoint = CGPoint(x: 0.5, y: 1)
            maskLayer.endPoint = CGPoint(x: 0.5, y: 0)
        }
    }
}
