import UIKit

final class RatingView: UIStackView {
    private let maxRating = 5

    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        spacing = 2
        for _ in 0..<maxRating {
            let star = UIImageView(image: UIImage(systemName: "star.fill"))
            star.contentMode = .scaleAspectFit
            star.translatesAutoresizingMaskIntoConstraints = false
            star.widthAnchor.constraint(equalToConstant: 12).isActive = true
            star.heightAnchor.constraint(equalToConstant: 12).isActive = true
            addArrangedSubview(star)
        }
        setRating(0)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setRating(_ rating: Int) {
        for (index, star) in arrangedSubviews.enumerated() {
            star.tintColor = index < rating ? .ypYellow : .ypLightGrey
        }
    }
}
