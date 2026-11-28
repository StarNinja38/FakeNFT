import UIKit

final class TabBarController: UITabBarController {

    private let servicesAssembly: ServicesAssembly

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let sortStorage = SortStorageImpl()
        let profile = ProfileViewController(
            viewModel: ProfileViewModel(service: servicesAssembly.profileService)
        )
        let catalog = CatalogViewController(
            viewModel: CatalogViewModel(service: servicesAssembly.collectionsService, sortStorage: sortStorage)
        )
        let cart = CartViewController(
            viewModel: CartViewModel(
                orderService: servicesAssembly.orderService,
                nftService: servicesAssembly.nftService
            )
        )
        let statistics = StatisticsViewController(
            viewModel: StatisticsViewModel(service: servicesAssembly.usersService, sortStorage: sortStorage)
        )

        viewControllers = [
            makeTab(profile, title: "Tab.profile", image: "person.crop.circle.fill"),
            makeTab(catalog, title: "Tab.catalog", image: "square.stack.3d.up.fill"),
            makeTab(cart, title: "Tab.cart", image: "cart.fill"),
            makeTab(statistics, title: "Tab.statistics", image: "flag.2.crossed.fill")
        ]
        selectedIndex = 1

        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypBlack
        tabBar.backgroundColor = .ypWhite
        view.backgroundColor = .ypWhite
    }

    private func makeTab(_ controller: UIViewController, title: String, image: String) -> UIViewController {
        let navigation = UINavigationController(rootViewController: controller)
        navigation.tabBarItem = UITabBarItem(
            title: NSLocalizedString(title, comment: ""),
            image: UIImage(systemName: image),
            selectedImage: nil
        )
        return navigation
    }
}
