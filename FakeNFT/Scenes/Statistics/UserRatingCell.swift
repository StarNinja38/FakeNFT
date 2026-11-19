import Kingfisher
import UIKit

final class UserRatingCell: UITableViewCell, ReuseIdentifying {

    private let placeLabel: UILabel = {
        let label = UILabel()
        label.font = .caption1
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGrey
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 14
        imageView.clipsToBounds = true
        imageView.tintColor = .ypGrey
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .headline2
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .headline2
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
    }

    func configure(with model: UserRatingCellModel) {
        placeLabel.text = model.place
        nameLabel.text = model.name
        countLabel.text = model.nftCount
        avatarImageView.kf.setImage(
            with: model.avatarURL,
            placeholder: UIImage(systemName: "person.crop.circle.fill")
        )
    }

    private func setupLayout() {
        contentView.addSubview(placeLabel)
        contentView.addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(countLabel)
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            placeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            placeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            placeLabel.widthAnchor.constraint(equalToConstant: 27),

            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: placeLabel.trailingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 28),
            avatarImageView.heightAnchor.constraint(equalToConstant: 28),

            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: countLabel.leadingAnchor, constant: -8),

            countLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            countLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
}
