import Foundation

protocol OrderRepositoryProtocol {
    func checkout() async throws
    func getOrders() async throws -> [OrderAPIResponse]
    func getOrderDetail(id: String) async throws -> OrderAPIResponse
}

final class OrderRepository: OrderRepositoryProtocol {
    private let apiService: any OrderAPIServiceProtocol

    init(apiService: any OrderAPIServiceProtocol) {
        self.apiService = apiService
    }

    func checkout() async throws {
        let response = try await apiService.checkout()
        if response.success == false {
            throw APIError.apiError(response.message ?? "Checkout failed")
        }
    }

    func getOrders() async throws -> [OrderAPIResponse] {
        let response = try await apiService.getOrders()
        return response.data ?? []
    }

    func getOrderDetail(id: String) async throws -> OrderAPIResponse {
        let response = try await apiService.getOrderDetail(id: id)
        guard let order = response.data else {
            throw APIError.apiError("Order not found")
        }
        return order
    }
}
