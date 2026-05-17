import Foundation

protocol ProductCategoryAPIServiceProtocol {
    func getCategories() async throws -> APIResponse<CategoriesResponse>
    func getCategoryDetail(id: String) async throws -> APIResponse<CategoryDetail>
}

final class ProductCategoryAPIService: ProductCategoryAPIServiceProtocol {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getCategories() async throws -> APIResponse<CategoriesResponse> {
        try await networkService.request(
            endpoint: NetworkConfig.Endpoint.productCategories,
            method: .get
        )
    }

    func getCategoryDetail(id: String) async throws -> APIResponse<CategoryDetail> {
        try await networkService.request(
            endpoint: NetworkConfig.Endpoint.productCategory(id: id)
        )
    }
}
