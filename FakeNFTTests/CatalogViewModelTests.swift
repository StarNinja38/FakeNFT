@testable import FakeNFT
import XCTest

final class CatalogViewModelTests: XCTestCase {

    private let collections = [
        CatalogViewModelTests.makeCollection(name: "Brown", count: 1),
        CatalogViewModelTests.makeCollection(name: "Apple", count: 3),
        CatalogViewModelTests.makeCollection(name: "Cats", count: 2)
    ]

    func testFirstLaunchSortsByNftCount() {
        let service = CollectionsServiceStub()
        let viewModel = CatalogViewModel(service: service, sortStorage: SortStorageStub())

        load(viewModel, service: service, result: .success(collections))

        XCTAssertEqual(viewModel.collections.map(\.name), ["Apple", "Cats", "Brown"])
    }

    func testRestoresSavedSort() {
        let service = CollectionsServiceStub()
        let storage = SortStorageStub(value: CatalogSort.name.rawValue)
        let viewModel = CatalogViewModel(service: service, sortStorage: storage)

        load(viewModel, service: service, result: .success(collections))

        XCTAssertEqual(viewModel.collections.map(\.name), ["Apple", "Brown", "Cats"])
    }

    func testSortChangedDuringLoadingIsApplied() {
        let service = CollectionsServiceStub()
        let storage = SortStorageStub()
        let viewModel = CatalogViewModel(service: service, sortStorage: storage)

        viewModel.loadCollections()
        viewModel.applySort(.name)
        finish(viewModel, service: service, result: .success(collections))

        XCTAssertEqual(viewModel.collections.map(\.name), ["Apple", "Brown", "Cats"])
        XCTAssertEqual(storage.value, CatalogSort.name.rawValue)
    }

    func testErrorStaysPendingUntilShown() {
        let service = CollectionsServiceStub()
        let viewModel = CatalogViewModel(service: service, sortStorage: SortStorageStub())

        load(viewModel, service: service, result: .failure(URLError(.notConnectedToInternet)))
        XCTAssertTrue(viewModel.hasPendingError)

        viewModel.errorDidShow()
        XCTAssertFalse(viewModel.hasPendingError)
    }

    // MARK: - helpers

    private func load(
        _ viewModel: CatalogViewModel,
        service: CollectionsServiceStub,
        result: Result<[NftCollection], Error>
    ) {
        viewModel.loadCollections()
        finish(viewModel, service: service, result: result)
    }

    private func finish(
        _ viewModel: CatalogViewModel,
        service: CollectionsServiceStub,
        result: Result<[NftCollection], Error>
    ) {
        let done = expectation(description: "load finished")
        viewModel.onCollectionsChange = { done.fulfill() }
        viewModel.onError = { done.fulfill() }
        service.complete(with: result)
        wait(for: [done], timeout: 1)
    }

    private static func makeCollection(name: String, count: Int) -> NftCollection {
        NftCollection(
            id: name,
            name: name,
            cover: "",
            nfts: (0..<count).map(String.init),
            description: "",
            author: "",
            website: ""
        )
    }
}

private final class CollectionsServiceStub: CollectionsService {
    private var completion: ((Result<[NftCollection], Error>) -> Void)?

    func loadCollections(completion: @escaping (Result<[NftCollection], Error>) -> Void) {
        self.completion = completion
    }

    func complete(with result: Result<[NftCollection], Error>) {
        completion?(result)
    }
}

private final class SortStorageStub: SortStorage {
    var value: String?

    init(value: String? = nil) {
        self.value = value
    }

    func sortValue(for screen: SortScreen) -> String? {
        value
    }

    func saveSortValue(_ value: String, for screen: SortScreen) {
        self.value = value
    }
}
