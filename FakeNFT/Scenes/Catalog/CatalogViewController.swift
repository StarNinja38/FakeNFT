import UIKit

final class CatalogViewController: UIViewController, LoadingView, ErrorView {

    let activityIndicator = UIActivityIndicatorView(style: .large)

    private let viewModel: CatalogViewModel

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CatalogCell.self)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypWhite
        tableView.rowHeight = 187
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    init(viewModel: CatalogViewModel) {
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
        viewModel.loadCollections()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showErrorIfPossible()
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
        viewModel.onCollectionsChange = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.onLoadingChange = { [weak self] isLoading in
            isLoading ? self?.showLoading() : self?.hideLoading()
        }
        viewModel.onError = { [weak self] in
            self?.showErrorIfPossible()
        }
    }

    // алерт показываю только когда каталог на экране и меню сортировки закрыто
    private func showErrorIfPossible() {
        guard viewModel.hasPendingError, view.window != nil, presentedViewController == nil else { return }
        viewModel.errorDidShow()
        showNetworkError { [weak self] in
            self?.viewModel.loadCollections()
        }
    }

    @objc private func sortTapped() {
        showSortSheet(options: [
            SortOption(title: NSLocalizedString("Sort.byName", comment: "")) { [weak self] in
                self?.viewModel.applySort(.name)
            },
            SortOption(title: NSLocalizedString("Sort.byNftCount", comment: "")) { [weak self] in
                self?.viewModel.applySort(.nftCount)
            }
        ], onClose: { [weak self] in
            self?.showErrorIfPossible()
        })
    }
}

// MARK: - UITableViewDataSource

extension CatalogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.collections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CatalogCell = tableView.dequeueReusableCell()
        cell.configure(with: viewModel.cellModel(at: indexPath.row))
        return cell
    }
}
