import Foundation

@Observable
@MainActor
final class OrdersViewModel {
    enum State {
        case idle, loading, success([OrderAPIResponse]), error(String)
    }

    private(set) var state: State = .idle

    private let orderRepository: any OrderRepositoryProtocol

    nonisolated init(orderRepository: any OrderRepositoryProtocol) {
        self.orderRepository = orderRepository
    }

    func loadOrders() async {
        state = .loading
        do {
            let orders = try await orderRepository.getOrders()
            state = .success(orders)
        } catch let e as APIError {
            state = .error(e.localizedDescription)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
