import Foundation

struct CollectionHeaderModel {
    let title: String
    let author: String
    let description: String
    let coverURL: URL?
}

final class CollectionViewModel {
    var onContentChange: (() -> Void)?
    var onLoadingChange: ((Bool) -> Void)?
    var onError: (() -> Void)?

    private(set) var header: CollectionHeaderModel?
    private(set) var nfts: [Nft] = []
    private(set) var hasPendingError = false

    private let collectionId: String
    private let collectionsService: CollectionsService
    private let nftService: NftService
    private let profileService: ProfileService
    private let orderService: OrderService

    private var likes: Set<String> = []
    private var cartIds: Set<String> = []

    init(
        collectionId: String,
        collectionsService: CollectionsService,
        nftService: NftService,
        profileService: ProfileService,
        orderService: OrderService
    ) {
        self.collectionId = collectionId
        self.collectionsService = collectionsService
        self.nftService = nftService
        self.profileService = profileService
        self.orderService = orderService
    }

    func load() {
        hasPendingError = false
        onLoadingChange?(true)

        // все ответы приходят на main, поэтому общие переменные трогаю только оттуда
        let group = DispatchGroup()
        let nftService = nftService
        var collection: NftCollection?
        var loadedNfts: [Nft] = []
        var profile: Profile?
        var order: Order?
        var failed = false

        group.enter()
        collectionsService.loadCollection(id: collectionId) { result in
            switch result {
            case .success(let loaded):
                collection = loaded
                group.enter()
                nftService.loadNfts(ids: loaded.nfts) { result in
                    switch result {
                    case .success(let nfts):
                        loadedNfts = nfts
                    case .failure:
                        failed = true
                    }
                    group.leave()
                }
            case .failure:
                failed = true
            }
            group.leave()
        }

        group.enter()
        profileService.loadProfile { result in
            profile = try? result.get()
            group.leave()
        }

        group.enter()
        orderService.loadOrder { result in
            order = try? result.get()
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.onLoadingChange?(false)
            guard !failed, let collection, let profile, let order else {
                self.hasPendingError = true
                self.onError?()
                return
            }
            self.header = CollectionHeaderModel(
                title: collection.name,
                author: collection.author,
                description: collection.description,
                coverURL: collection.coverURL
            )
            self.nfts = loadedNfts
            self.likes = Set(profile.likes)
            self.cartIds = Set(order.nfts)
            self.onContentChange?()
        }
    }

    func errorDidShow() {
        hasPendingError = false
    }

    func cellModel(at index: Int) -> NftCellModel {
        let nft = nfts[index]
        return NftCellModel(
            id: nft.id,
            name: nft.name,
            imageURL: nft.images.first,
            rating: nft.rating,
            price: PriceFormatter.eth(nft.price),
            isLiked: likes.contains(nft.id),
            isInCart: cartIds.contains(nft.id)
        )
    }
}
