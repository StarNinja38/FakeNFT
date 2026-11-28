import Foundation

protocol SortStorage {
    func sortValue(for screen: SortScreen) -> String?
    func saveSortValue(_ value: String, for screen: SortScreen)
}

enum SortScreen: String {
    case catalog
    case cart
    case myNfts
    case statistics
}

final class SortStorageImpl: SortStorage {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func sortValue(for screen: SortScreen) -> String? {
        defaults.string(forKey: key(for: screen))
    }

    func saveSortValue(_ value: String, for screen: SortScreen) {
        defaults.set(value, forKey: key(for: screen))
    }

    private func key(for screen: SortScreen) -> String {
        "sort.\(screen.rawValue)"
    }
}
