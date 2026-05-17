import Foundation

@Observable
@MainActor
final class OrderDetailViewModel {
    enum State {
        case idle, loading, success(OrderAPIResponse), error(String)
    }

    private(set) var state: State = .idle

    private let orderRepository: any OrderRepositoryProtocol

    nonisolated init(orderRepository: any OrderRepositoryProtocol) {
        self.orderRepository = orderRepository
    }

    func loadOrder(id: String) async {
        state = .loading
        do {
            let order = try await orderRepository.getOrderDetail(id: id)
            state = .success(order)
        } catch let e as APIError {
            state = .error(e.localizedDescription)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
