import Foundation

enum StatisticsSort: String {
    case name
    case rating
}

struct UserRatingCellModel {
    let place: String
    let name: String
    let avatarURL: URL?
    let nftCount: String
}

final class StatisticsViewModel {
    var onUsersChange: (() -> Void)?
    var onLoadingChange: ((Bool) -> Void)?
    var onError: (() -> Void)?

    private(set) var users: [User] = []

    private let service: UsersService
    private let sortStorage: SortStorage
    private var sort: StatisticsSort
    // место считаю по количеству NFT и не меняю при сортировке по имени
    private var places: [String: Int] = [:]

    init(service: UsersService, sortStorage: SortStorage) {
        self.service = service
        self.sortStorage = sortStorage
        let saved = sortStorage.sortValue(for: .statistics).flatMap(StatisticsSort.init(rawValue:))
        sort = saved ?? .rating
    }

    func loadUsers() {
        onLoadingChange?(true)
        let sort = sort
        service.loadUsers { [weak self] result in
            guard let self else { return }
            let users = try? result.get()
            let places = users.map(self.makePlaces)
            let sorted = users.map { self.sorted($0, by: sort) }
            DispatchQueue.main.async {
                self.onLoadingChange?(false)
                guard let sorted, let places else {
                    self.onError?()
                    return
                }
                self.places = places
                self.users = sorted
                self.onUsersChange?()
            }
        }
    }

    func applySort(_ sort: StatisticsSort) {
        self.sort = sort
        sortStorage.saveSortValue(sort.rawValue, for: .statistics)
        users = sorted(users, by: sort)
        onUsersChange?()
    }

    func cellModel(at index: Int) -> UserRatingCellModel {
        let user = users[index]
        return UserRatingCellModel(
            place: "\(places[user.id] ?? index + 1)",
            name: user.name,
            avatarURL: user.avatar.flatMap(URL.init(string:)),
            nftCount: "\(user.nfts.count)"
        )
    }

    private func makePlaces(for users: [User]) -> [String: Int] {
        let byRating = sorted(users, by: .rating)
        var places: [String: Int] = [:]
        for (index, user) in byRating.enumerated() {
            places[user.id] = index + 1
        }
        return places
    }

    private func sorted(_ users: [User], by sort: StatisticsSort) -> [User] {
        switch sort {
        case .name:
            return users.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .rating:
            return users.sorted { $0.nfts.count > $1.nfts.count }
        }
    }
}
