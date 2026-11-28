import UIKit

final class StatisticsViewController: UIViewController, LoadingView, ErrorView {

    let activityIndicator = UIActivityIndicatorView(style: .large)

    private let viewModel: StatisticsViewModel

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UserRatingCell.self)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypWhite
        tableView.rowHeight = 88
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    init(viewModel: StatisticsViewModel) {
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
        viewModel.loadUsers()
    }

    private func setupView() {
        view.backgroundColor = .ypWhite
        navigationItem.rightBarButtonItem = makeSortButton(action: #selector(sortTapped))

        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onUsersChange = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.onLoadingChange = { [weak self] isLoading in
            isLoading ? self?.showLoading() : self?.hideLoading()
        }
        viewModel.onError = { [weak self] in
            self?.showNetworkError { self?.viewModel.loadUsers() }
        }
    }

    @objc private func sortTapped() {
        showSortSheet(options: [
            SortOption(title: NSLocalizedString("Sort.byName", comment: "")) { [weak self] in
                self?.viewModel.applySort(.name)
            },
            SortOption(title: NSLocalizedString("Sort.byRating", comment: "")) { [weak self] in
                self?.viewModel.applySort(.rating)
            }
        ])
    }
}

// MARK: - UITableViewDataSource

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserRatingCell = tableView.dequeueReusableCell()
        cell.configure(with: viewModel.cellModel(at: indexPath.row))
        return cell
    }
}
