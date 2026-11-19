import UIKit

final class CartViewController: UIViewController, LoadingView, ErrorView {

    let activityIndicator = UIActivityIndicatorView(style: .large)

    private let viewModel: CartViewModel

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CartCell.self)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypWhite
        tableView.rowHeight = 140
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let bottomPanel: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGrey
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .caption1
        label.textColor = .ypBlack
        return label
    }()

    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .ypGreen
        return label
    }()

    private let payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Cart.pay", comment: ""), for: .normal)
        button.titleLabel?.font = .bodyBold
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .ypBlack
        label.text = NSLocalizedString("Cart.empty", comment: "")
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(viewModel: CartViewModel) {
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // корзина могла измениться на других вкладках
        viewModel.loadCart()
    }

    private func setupView() {
        view.backgroundColor = .ypWhite

        let textStack = UIStackView(arrangedSubviews: [countLabel, totalLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(bottomPanel)
        bottomPanel.addSubview(textStack)
        bottomPanel.addSubview(payButton)
        view.addSubview(emptyLabel)
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomPanel.topAnchor),

            bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomPanel.heightAnchor.constraint(equalToConstant: 76),

            textStack.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: 16),
            textStack.centerYAnchor.constraint(equalTo: bottomPanel.centerYAnchor),

            payButton.leadingAnchor.constraint(equalTo: textStack.trailingAnchor, constant: 24),
            payButton.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -16),
            payButton.centerYAnchor.constraint(equalTo: bottomPanel.centerYAnchor),
            payButton.heightAnchor.constraint(equalToConstant: 44),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        textStack.setContentHuggingPriority(.required, for: .horizontal)
    }

    private func bindViewModel() {
        viewModel.onItemsChange = { [weak self] in
            self?.updateContent()
        }
        viewModel.onLoadingChange = { [weak self] isLoading in
            isLoading ? self?.showLoading() : self?.hideLoading()
        }
        viewModel.onError = { [weak self] in
            self?.showNetworkError { self?.viewModel.loadCart() }
        }
    }

    private func updateContent() {
        let isEmpty = viewModel.isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        bottomPanel.isHidden = isEmpty
        countLabel.text = viewModel.countText
        totalLabel.text = viewModel.totalText
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CartCell = tableView.dequeueReusableCell()
        cell.configure(with: viewModel.cellModel(at: indexPath.row))
        return cell
    }
}
