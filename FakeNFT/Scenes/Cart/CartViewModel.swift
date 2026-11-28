import Foundation

struct CartCellModel {
    let name: String
    let imageURL: URL?
    let rating: Int
    let price: String
}

final class CartViewModel {
    var onItemsChange: (() -> Void)?
    var onLoadingChange: ((Bool) -> Void)?
    var onError: (() -> Void)?

    private(set) var items: [Nft] = []

    private let orderService: OrderService
    private let nftService: NftService

    init(orderService: OrderService, nftService: NftService) {
        self.orderService = orderService
        self.nftService = nftService
    }

    var isEmpty: Bool { items.isEmpty }

    var countText: String {
        "\(items.count) NFT"
    }

    var totalText: String {
        PriceFormatter.eth(items.reduce(0) { $0 + $1.price })
    }

    func loadCart() {
        onLoadingChange?(true)
        orderService.loadOrder { [weak self] result in
            switch result {
            case .success(let order):
                self?.loadNfts(ids: order.nfts)
            case .failure:
                self?.finishLoading(with: nil)
            }
        }
    }

    func cellModel(at index: Int) -> CartCellModel {
        let nft = items[index]
        return CartCellModel(
            name: nft.name,
            imageURL: nft.images.first,
            rating: nft.rating,
            price: PriceFormatter.eth(nft.price)
        )
    }

    private func loadNfts(ids: [String]) {
        nftService.loadNfts(ids: ids) { [weak self] result in
            self?.finishLoading(with: try? result.get())
        }
    }

    private func finishLoading(with nfts: [Nft]?) {
        onLoadingChange?(false)
        guard let nfts else {
            onError?()
            return
        }
        // пока сортирую по названию, выбор сортировки будет во второй части
        items = nfts.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        onItemsChange?()
    }
}
