import UIKit

final class CollectionViewController: UIViewController, LoadingView, ErrorView {

    let activityIndicator = UIActivityIndicatorView(style: .large)

    private let viewModel: CollectionViewModel

    private let columns: CGFloat = 3
    private let sideInset: CGFloat = 16
    private let columnSpacing: CGFloat = 9
    private let rowSpacing: CGFloat = 8
    // под картинкой рейтинг, название и цена
    private let cellInfoHeight: CGFloat = 84

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = columnSpacing
        layout.minimumLineSpacing = rowSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(NftCollectionCell.self)
        collectionView.register(
            CollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionHeaderView.defaultReuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .ypWhite
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    // по нему считаю высоту шапки
    private let sizingHeader = CollectionHeaderView()

    init(viewModel: CollectionViewModel) {
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
        viewModel.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showErrorIfPossible()
    }

    private func setupView() {
        view.backgroundColor = .ypWhite

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance

        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onContentChange = { [weak self] in
            self?.collectionView.reloadData()
        }
        viewModel.onLoadingChange = { [weak self] isLoading in
            isLoading ? self?.showLoading() : self?.hideLoading()
        }
        viewModel.onError = { [weak self] in
            self?.showErrorIfPossible()
        }
    }

    // как в каталоге, алерт только когда экран виден и поверх ничего не открыто
    private func showErrorIfPossible() {
        guard viewModel.hasPendingError, view.window != nil, presentedViewController == nil else { return }
        viewModel.errorDidShow()
        showNetworkError { [weak self] in
            self?.viewModel.load()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.nfts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NftCollectionCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.configure(with: viewModel.cellModel(at: indexPath.item))
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CollectionHeaderView.defaultReuseIdentifier,
                for: indexPath
            ) as? CollectionHeaderView
        else { return UICollectionReusableView() }
        if let model = viewModel.header {
            header.configure(with: model)
        }
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let available = collectionView.bounds.width - sideInset * 2 - columnSpacing * (columns - 1)
        let width = floor(available / columns)
        return CGSize(width: width, height: width + cellInfoHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: sideInset, bottom: 16, right: sideInset)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard let model = viewModel.header else { return .zero }
        sizingHeader.configure(with: model)
        let width = collectionView.bounds.width
        let size = sizingHeader.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: width, height: size.height)
    }
}
