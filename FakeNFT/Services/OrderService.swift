import Foundation

protocol OrderService {
    func loadOrder(completion: @escaping (Result<Order, Error>) -> Void)
}

final class OrderServiceImpl: OrderService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadOrder(completion: @escaping (Result<Order, Error>) -> Void) {
        networkClient.send(request: OrderRequest(), type: Order.self, onResponse: completion)
    }
}
