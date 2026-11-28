import Foundation

protocol CollectionsService {
    func loadCollections(completion: @escaping (Result<[NftCollection], Error>) -> Void)
    func loadCollection(id: String, completion: @escaping (Result<NftCollection, Error>) -> Void)
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

    func loadCollection(id: String, completion: @escaping (Result<NftCollection, Error>) -> Void) {
        networkClient.send(
            request: CollectionByIdRequest(id: id),
            type: NftCollection.self,
            onResponse: completion
        )
    }
}
