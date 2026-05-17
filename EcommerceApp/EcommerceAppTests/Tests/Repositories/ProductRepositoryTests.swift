import Foundation
import Testing
@testable import EcommerceApp

struct ProductRepositoryTests {

    @Test func getProduct_success_returnsProduct() async throws {
        let service = MockProductAPIService()
        service.stubbedProduct = makeProduct()
        let repo = ProductRepository(apiService: service)
        let product = try await repo.getProduct(id: "p1")
        #expect(product.name == "Headphones")
    }

    @Test func getProduct_nilData_throws() async throws {
        let service = MockProductAPIService()
        service.stubbedProduct = nil
        let repo = ProductRepository(apiService: service)
        await #expect(throws: (any Error).self) {
            try await repo.getProduct(id: "p1")
        }
    }

    @Test func getProduct_networkTimeout_propagatesThrow() async throws {
        let service = MockProductAPIService()
        service.getProductError = URLError(.timedOut)
        let repo = ProductRepository(apiService: service)
        await #expect(throws: (any Error).self) {
            try await repo.getProduct(id: "p1")
        }
    }
}
