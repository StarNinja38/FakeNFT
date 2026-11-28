import Kingfisher
import UIKit

final class ProfileViewController: UIViewController, LoadingView, ErrorView {

    let activityIndicator = UIActivityIndicatorView(style: .large)

    private let viewModel: ProfileViewModel

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.tintColor = .ypLightGrey
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .headline2
        label.textColor = .ypBlack
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .ypBlack
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let websiteLabel: UILabel = {
        let label = UILabel()
        label.font = .caption1
        label.textColor = .ypBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellId)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 54
        tableView.backgroundColor = .ypWhite
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        viewModel.loadProfile()
    }

    private func setupView() {
        view.backgroundColor = .ypWhite
        // экран редактирования будет в третьей части
        let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: nil, action: nil)
        editButton.tintColor = .ypBlack
        navigationItem.rightBarButtonItem = editButton

        [avatarImageView, nameLabel, descriptionLabel, websiteLabel, tableView, activityIndicator].forEach {
            view.addSubview($0)
        }
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            websiteLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            websiteLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            websiteLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: websiteLabel.bottomAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 54 * CGFloat(ProfileSection.allCases.count)),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onProfileChange = { [weak self] in
            self?.updateContent()
        }
        viewModel.onLoadingChange = { [weak self] isLoading in
            isLoading ? self?.showLoading() : self?.hideLoading()
        }
        viewModel.onError = { [weak self] in
            self?.showNetworkError { self?.viewModel.loadProfile() }
        }
    }

    private func updateContent() {
        nameLabel.text = viewModel.name
        descriptionLabel.text = viewModel.description
        websiteLabel.text = viewModel.website
        avatarImageView.kf.setImage(
            with: viewModel.avatarURL,
            placeholder: UIImage(systemName: "person.crop.circle.fill")
        )
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ProfileSection.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId, for: indexPath)
        guard let section = ProfileSection(rawValue: indexPath.row) else { return cell }
        var content = cell.defaultContentConfiguration()
        content.text = viewModel.title(for: section)
        content.textProperties.font = .bodyBold
        content.textProperties.color = .ypBlack
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.forward"))
        cell.accessoryView?.tintColor = .ypBlack
        return cell
    }
}

private enum Constants {
    static let cellId = "ProfileCell"
}
