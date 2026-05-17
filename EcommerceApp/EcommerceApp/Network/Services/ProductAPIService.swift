import Foundation

protocol ProductAPIServiceProtocol {
    func getProduct(id: String) async throws -> APIResponse<ProductDetailResponse>
}

final class ProductAPIService: ProductAPIServiceProtocol {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getProduct(id: String) async throws -> APIResponse<ProductDetailResponse> {
        try await networkService.request(
            endpoint: NetworkConfig.Endpoint.product(id: id)
        )
    }
}