import Kingfisher
import UIKit

struct NftCellModel {
    let id: String
    let name: String
    let imageURL: URL?
    let rating: Int
    let price: String
    let isLiked: Bool
    let isInCart: Bool
}

final class NftCollectionCell: UICollectionViewCell, ReuseIdentifying {

    var onLikeTap: (() -> Void)?
    var onCartTap: (() -> Void)?

    private static let iconConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)

    private static let addToCartImage = UIImage(systemName: "cart.badge.plus", withConfiguration: iconConfig)

    // в sf symbols нет корзины с крестиком, поэтому рисую её сам
    private static let inCartImage: UIImage? = {
        let crossConfig = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
        guard
            let cart = UIImage(systemName: "cart", withConfiguration: iconConfig),
            let cross = UIImage(systemName: "xmark", withConfiguration: crossConfig)
        else { return nil }
        let size = CGSize(width: cart.size.width + 4, height: cart.size.height + 4)
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            cart.draw(at: CGPoint(x: 0, y: 4))
            cross.draw(at: CGPoint(x: size.width - cross.size.width, y: 0))
        }
        return image.withRenderingMode(.alwaysTemplate)
    }()

    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = .ypLightGrey
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "heart.fill", withConfiguration: Self.iconConfig), for: .normal)
        button.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let ratingView: RatingView = {
        let view = RatingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .caption3
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var cartButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .ypBlack
        button.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
        onLikeTap = nil
        onCartTap = nil
    }

    func configure(with model: NftCellModel) {
        nftImageView.kf.setImage(with: model.imageURL)
        nameLabel.text = model.name
        priceLabel.text = model.price
        ratingView.setRating(model.rating)
        likeButton.tintColor = model.isLiked ? .ypRed : .white
        cartButton.setImage(model.isInCart ? Self.inCartImage : Self.addToCartImage, for: .normal)
    }

    private func setupLayout() {
        [nftImageView, likeButton, ratingView, nameLabel, priceLabel, cartButton].forEach {
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftImageView.heightAnchor.constraint(equalTo: nftImageView.widthAnchor),

            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 40),
            likeButton.heightAnchor.constraint(equalToConstant: 40),

            ratingView.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 8),
            ratingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            nameLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: cartButton.leadingAnchor),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: cartButton.leadingAnchor),

            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cartButton.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            cartButton.widthAnchor.constraint(equalToConstant: 40),
            cartButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func likeTapped() {
        onLikeTap?()
    }

    @objc private func cartTapped() {
        onCartTap?()
    }
}
