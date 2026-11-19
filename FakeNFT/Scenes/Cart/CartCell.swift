import Kingfisher
import UIKit

final class CartCell: UITableViewCell, ReuseIdentifying {

    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = .ypLightGrey
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .ypBlack
        return label
    }()

    private let ratingView = RatingView()

    private let priceTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .ypBlack
        label.text = NSLocalizedString("Cart.price", comment: "")
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .ypBlack
        return label
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "cart.badge.minus"), for: .normal)
        button.tintColor = .ypBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
    }

    func configure(with model: CartCellModel) {
        nameLabel.text = model.name
        ratingView.setRating(model.rating)
        priceLabel.text = model.price
        nftImageView.kf.setImage(with: model.imageURL)
    }

    private func setupLayout() {
        let topStack = UIStackView(arrangedSubviews: [nameLabel, ratingView])
        topStack.axis = .vertical
        topStack.alignment = .leading
        topStack.spacing = 4

        let priceStack = UIStackView(arrangedSubviews: [priceTitleLabel, priceLabel])
        priceStack.axis = .vertical
        priceStack.alignment = .leading
        priceStack.spacing = 2

        let infoStack = UIStackView(arrangedSubviews: [topStack, priceStack])
        infoStack.axis = .vertical
        infoStack.alignment = .leading
        infoStack.spacing = 12
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(nftImageView)
        contentView.addSubview(infoStack)
        contentView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),

            infoStack.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            infoStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoStack.trailingAnchor.constraint(lessThanOrEqualTo: deleteButton.leadingAnchor, constant: -8),

            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 40),
            deleteButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
