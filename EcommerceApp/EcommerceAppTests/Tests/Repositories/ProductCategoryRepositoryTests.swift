import Foundation
import Testing
@testable import EcommerceApp

struct ProductCategoryRepositoryTests {

    @Test func getCategories_mapsResponseToArray() async throws {
        let service = MockProductCategoryAPIService()
        service.stubbedCategories = [makeCategory()]
        let repo = ProductCategoryRepository(apiService: service)
        let categories = try await repo.getCategories()
        #expect(categories.count == 1)
        #expect(categories[0].id == "c1")
    }

    @Test func getCategories_emptyResponse_returnsEmpty() async throws {
        let service = MockProductCategoryAPIService()
        let repo = ProductCategoryRepository(apiService: service)
        let categories = try await repo.getCategories()
        #expect(categories.isEmpty)
    }

    @Test func getCategoryDetail_success_returnsDetail() async throws {
        let service = MockProductCategoryAPIService()
        service.stubbedCategoryDetail = makeCategoryDetail()
        let repo = ProductCategoryRepository(apiService: service)
        let detail = try await repo.getCategoryDetail(id: "c1")
        #expect(detail.category.id == "c1")
    }

    @Test func getCategoryDetail_nilData_throws() async throws {
        let service = MockProductCategoryAPIService()
        service.stubbedCategoryDetail = nil
        let repo = ProductCategoryRepository(apiService: service)
        await #expect(throws: (any Error).self) {
            try await repo.getCategoryDetail(id: "c1")
        }
    }

    @Test func getCategories_networkTimeout_propagatesThrow() async throws {
        let service = MockProductCategoryAPIService()
        service.getCategoriesError = URLError(.timedOut)
        let repo = ProductCategoryRepository(apiService: service)
        await #expect(throws: (any Error).self) {
            try await repo.getCategories()
        }
    }
}
