import Foundation

final class CartAPIService {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getCart() async throws -> APIResponse<CartAPIResponse> {
        try await networkService.authenticatedRequest(endpoint: NetworkConfig.Endpoint.cart)
    }

    func addToCart(productId: String, quantity: Int) async throws {
        let _: APIResponse<EmptyResponse> = try await networkService.authenticatedRequest(
            endpoint: NetworkConfig.Endpoint.cartAdd,
            method: .post,
            body: AddToCartRequest(productId: productId, quantity: quantity)
        )
    }

    func removeFromCart(productId: String) async throws {
        let _: APIResponse<EmptyResponse> = try await networkService.authenticatedRequest(
            endpoint: "/api/cart/\(productId)",
            method: .delete
        )
    }
}
