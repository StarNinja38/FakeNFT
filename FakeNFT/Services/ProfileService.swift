import Foundation

protocol ProfileService {
    func loadProfile(completion: @escaping (Result<Profile, Error>) -> Void)
}

final class ProfileServiceImpl: ProfileService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        networkClient.send(request: ProfileRequest(), type: Profile.self, onResponse: completion)
    }
}
