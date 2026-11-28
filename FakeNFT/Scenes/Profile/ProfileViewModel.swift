import Foundation

enum ProfileSection: Int, CaseIterable {
    case myNfts
    case favorites
}

final class ProfileViewModel {
    var onProfileChange: (() -> Void)?
    var onLoadingChange: ((Bool) -> Void)?
    var onError: (() -> Void)?

    private(set) var profile: Profile?

    private let service: ProfileService

    init(service: ProfileService) {
        self.service = service
    }

    var name: String { profile?.name ?? "" }
    var description: String { profile?.description ?? "" }
    var website: String { profile?.website ?? "" }
    var avatarURL: URL? { profile?.avatar.flatMap(URL.init(string:)) }

    func loadProfile() {
        onLoadingChange?(true)
        service.loadProfile { [weak self] result in
            guard let self else { return }
            self.onLoadingChange?(false)
            switch result {
            case .success(let profile):
                self.profile = profile
                self.onProfileChange?()
            case .failure:
                self.onError?()
            }
        }
    }

    func title(for section: ProfileSection) -> String {
        switch section {
        case .myNfts:
            let format = NSLocalizedString("Profile.myNfts", comment: "")
            return String(format: format, profile?.nfts.count ?? 0)
        case .favorites:
            let format = NSLocalizedString("Profile.favorites", comment: "")
            return String(format: format, profile?.likes.count ?? 0)
        }
    }
}
