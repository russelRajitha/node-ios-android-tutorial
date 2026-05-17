import Foundation

protocol ProductRepositoryProtocol {
    func getProduct(id: String) async throws -> ProductDetail
}

final class ProductRepository: ProductRepositoryProtocol {
    private let apiService: any ProductAPIServiceProtocol

    init(apiService: any ProductAPIServiceProtocol) {
        self.apiService = apiService
    }

    func getProduct(id: String) async throws -> ProductDetail {
        let response = try await apiService.getProduct(id: id)
        guard let detail = response.data?.product else {
            throw APIError.apiError("Product not found")
        }
        return detail
    }
}