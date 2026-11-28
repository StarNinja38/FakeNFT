@testable import FakeNFT
import XCTest

final class CollectionViewModelTests: XCTestCase {

    private let collection = NftCollection(
        id: "c1",
        name: "Peach",
        cover: "",
        nfts: ["1", "2", "3"],
        description: "about",
        author: "John",
        website: ""
    )

    func testMarksLikesAndCart() {
        let viewModel = makeViewModel(likes: ["2"], cart: ["3"])

        loadAndWait(viewModel)

        XCTAssertEqual(viewModel.nfts.map(\.id), ["1", "2", "3"])
        XCTAssertEqual(viewModel.header?.title, "Peach")
        XCTAssertEqual(viewModel.header?.author, "John")
        XCTAssertFalse(viewModel.cellModel(at: 0).isLiked)
        XCTAssertTrue(viewModel.cellModel(at: 1).isLiked)
        XCTAssertFalse(viewModel.cellModel(at: 1).isInCart)
        XCTAssertTrue(viewModel.cellModel(at: 2).isInCart)
    }

    func testErrorWhenCollectionFails() {
        let viewModel = makeViewModel(likes: [], cart: [], collectionFails: true)

        let failed = expectation(description: "error")
        viewModel.onContentChange = { XCTFail("content should not load") }
        viewModel.onError = { failed.fulfill() }
        viewModel.load()
        wait(for: [failed], timeout: 1)

        XCTAssertTrue(viewModel.hasPendingError)
        XCTAssertTrue(viewModel.nfts.isEmpty)
    }

    // MARK: - helpers

    private func makeViewModel(likes: [String], cart: [String], collectionFails: Bool = false) -> CollectionViewModel {
        CollectionViewModel(
            collectionId: collection.id,
            collectionsService: CollectionServiceStub(collection: collection, fails: collectionFails),
            nftService: NftServiceStub(),
            profileService: ProfileServiceStub(likes: likes),
            orderService: OrderServiceStub(nfts: cart)
        )
    }

    private func loadAndWait(_ viewModel: CollectionViewModel) {
        let loaded = expectation(description: "loaded")
        viewModel.onContentChange = { loaded.fulfill() }
        viewModel.onError = { XCTFail("load should not fail") }
        viewModel.load()
        wait(for: [loaded], timeout: 1)
    }
}

private final class CollectionServiceStub: CollectionsService {
    private let collection: NftCollection
    private let fails: Bool

    init(collection: NftCollection, fails: Bool) {
        self.collection = collection
        self.fails = fails
    }

    func loadCollections(completion: @escaping (Result<[NftCollection], Error>) -> Void) {}

    func loadCollection(id: String, completion: @escaping (Result<NftCollection, Error>) -> Void) {
        let result: Result<NftCollection, Error> = fails ? .failure(URLError(.badServerResponse)) : .success(collection)
        DispatchQueue.main.async { completion(result) }
    }
}

private final class NftServiceStub: NftService {
    func loadNft(id: String, completion: @escaping NftCompletion) {}

    func loadNfts(ids: [String], completion: @escaping NftsCompletion) {
        let nfts = ids.map { Nft(id: $0, name: "nft \($0)", images: [], rating: 3, price: 1.5, author: "") }
        DispatchQueue.main.async { completion(.success(nfts)) }
    }
}

private final class ProfileServiceStub: ProfileService {
    private let likes: [String]

    init(likes: [String]) {
        self.likes = likes
    }

    func loadProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        let profile = Profile(id: "1", name: "", avatar: nil, description: nil, website: nil, nfts: [], likes: likes)
        DispatchQueue.main.async { completion(.success(profile)) }
    }
}

private final class OrderServiceStub: OrderService {
    private let nfts: [String]

    init(nfts: [String]) {
        self.nfts = nfts
    }

    func loadOrder(completion: @escaping (Result<Order, Error>) -> Void) {
        DispatchQueue.main.async { completion(.success(Order(id: "1", nfts: self.nfts))) }
    }
}
