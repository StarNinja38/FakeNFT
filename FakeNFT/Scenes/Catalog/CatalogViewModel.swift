import Foundation

enum CatalogSort: String {
    case name
    case nftCount
}

struct CatalogCellModel {
    let title: String
    let coverURL: URL?
}

final class CatalogViewModel {
    var onCollectionsChange: (() -> Void)?
    var onLoadingChange: ((Bool) -> Void)?
    var onError: (() -> Void)?

    private(set) var collections: [NftCollection] = []
    private(set) var hasPendingError = false

    private let service: CollectionsService
    private let sortStorage: SortStorage
    private var sort: CatalogSort

    init(service: CollectionsService, sortStorage: SortStorage) {
        self.service = service
        self.sortStorage = sortStorage
        let saved = sortStorage.sortValue(for: .catalog).flatMap(CatalogSort.init(rawValue:))
        sort = saved ?? .nftCount
    }

    func loadCollections() {
        hasPendingError = false
        onLoadingChange?(true)
        let sort = sort
        service.loadCollections { [weak self] result in
            guard let self else { return }
            // сортирую ещё в фоне, на main только отдаю результат
            let sorted = (try? result.get()).map { self.sorted($0, by: sort) }
            DispatchQueue.main.async {
                self.onLoadingChange?(false)
                guard let sorted else {
                    self.hasPendingError = true
                    self.onError?()
                    return
                }
                // пока шла загрузка, сортировку могли поменять
                self.collections = sort == self.sort ? sorted : self.sorted(sorted, by: self.sort)
                self.onCollectionsChange?()
            }
        }
    }

    func errorDidShow() {
        hasPendingError = false
    }

    func applySort(_ sort: CatalogSort) {
        self.sort = sort
        sortStorage.saveSortValue(sort.rawValue, for: .catalog)
        collections = sorted(collections, by: sort)
        onCollectionsChange?()
    }

    func cellModel(at index: Int) -> CatalogCellModel {
        let collection = collections[index]
        return CatalogCellModel(
            title: "\(collection.name) (\(collection.nfts.count))",
            coverURL: collection.coverURL
        )
    }

    private func sorted(_ collections: [NftCollection], by sort: CatalogSort) -> [NftCollection] {
        switch sort {
        case .name:
            return collections.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nftCount:
            return collections.sorted { $0.nfts.count > $1.nfts.count }
        }
    }
}
