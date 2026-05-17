import Foundation

protocol OrderAPIServiceProtocol {
    func checkout() async throws -> APIResponse<OrderAPIResponse>
    func getOrders() async throws -> APIResponse<[OrderAPIResponse]>
    func getOrderDetail(id: String) async throws -> APIResponse<OrderAPIResponse>
}

final class OrderAPIService: OrderAPIServiceProtocol {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func checkout() async throws -> APIResponse<OrderAPIResponse> {
        try await networkService.authenticatedRequest(
            endpoint: NetworkConfig.Endpoint.ordersCheckout,
            method: .post
        )
    }

    func getOrders() async throws -> APIResponse<[OrderAPIResponse]> {
        try await networkService.authenticatedRequest(endpoint: NetworkConfig.Endpoint.orders)
    }

    func getOrderDetail(id: String) async throws -> APIResponse<OrderAPIResponse> {
        try await networkService.authenticatedRequest(endpoint: NetworkConfig.Endpoint.order(id: id))
    }
}
