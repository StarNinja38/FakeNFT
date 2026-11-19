import Foundation

protocol CollectionsService {
    func loadCollections(completion: @escaping (Result<[NftCollection], Error>) -> Void)
}

final class CollectionsServiceImpl: CollectionsService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadCollections(completion: @escaping (Result<[NftCollection], Error>) -> Void) {
        networkClient.send(
            request: CollectionsRequest(),
            type: [NftCollection].self,
            completionQueue: .global(qos: .userInitiated),
            onResponse: completion
        )
    }
}
