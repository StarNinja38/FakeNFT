import Foundation

protocol UsersService {
    func loadUsers(completion: @escaping (Result<[User], Error>) -> Void)
}

final class UsersServiceImpl: UsersService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        networkClient.send(
            request: UsersRequest(),
            type: [User].self,
            completionQueue: .global(qos: .userInitiated),
            onResponse: completion
        )
    }
}
