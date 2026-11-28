import Kingfisher
import UIKit

final class CollectionHeaderView: UICollectionReusableView, ReuseIdentifying {

    static let defaultReuseIdentifier = "CollectionHeaderView"

    var onAuthorTap: (() -> Void)?

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        imageView.backgroundColor = .ypLightGrey
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .headline2
        label.textColor = .ypBlack
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let authorTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .ypBlack
        label.text = NSLocalizedString("Collection.author", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var authorButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .caption1
        button.setTitleColor(.ypBlue, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.addTarget(self, action: #selector(authorTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .ypBlack
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with model: CollectionHeaderModel) {
        coverImageView.kf.setImage(with: model.coverURL)
        titleLabel.text = model.title
        authorButton.setTitle(model.author, for: .normal)
        descriptionLabel.text = model.description
    }

    private func setupLayout() {
        [coverImageView, titleLabel, authorTitleLabel, authorButton, descriptionLabel].forEach {
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 310),

            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            authorTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 13),
            authorTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            authorButton.leadingAnchor.constraint(equalTo: authorTitleLabel.trailingAnchor, constant: 4),
            authorButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            authorButton.lastBaselineAnchor.constraint(equalTo: authorTitleLabel.lastBaselineAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: authorTitleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }

    @objc private func authorTapped() {
        onAuthorTap?()
    }
}
