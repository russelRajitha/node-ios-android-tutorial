import Foundation

protocol ProductCategoryRepositoryProtocol {
    func getCategories() async throws -> [ProductCategory]
    func getCategoryDetail(id: String) async throws -> CategoryDetail
}

final class ProductCategoryRepository: ProductCategoryRepositoryProtocol {
    private let apiService: any ProductCategoryAPIServiceProtocol

    init(apiService: any ProductCategoryAPIServiceProtocol) {
        self.apiService = apiService
    }

    func getCategories() async throws -> [ProductCategory] {
        let response = try await apiService.getCategories()
        return response.data?.categories ?? []
    }

    func getCategoryDetail(id: String) async throws -> CategoryDetail {
        let response = try await apiService.getCategoryDetail(id: id)
        guard let detail = response.data else { throw APIError.apiError("No data found") }
        return detail
    }
}
