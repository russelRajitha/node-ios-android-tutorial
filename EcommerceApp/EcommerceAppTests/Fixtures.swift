import Foundation
import Testing
@testable import EcommerceApp

// MARK: - Domain fixtures
func makeCart(_ productId: String = "p1", name: String = "Headphones", price: Double = 79.99, qty: Int = 1) -> CartItem {
    CartItem(productId: productId, name: name, price: price, quantity: qty)
}

func makeProduct() -> ProductDetail {
    ProductDetail(id: "p1", name: "Headphones", description: "Desc", image: nil, price: "79.99", brand: "Sony", stock: 10, category: nil, images: [])
}

func makeCategory() -> ProductCategory {
    ProductCategory(id: "c1", name: "Electronics", icon: "laptop")
}

func makeCategoryDetail() -> CategoryDetail {
    CategoryDetail(category: makeCategory(), products: [], count: 0)
}

func makeOrder() -> OrderAPIResponse {
    OrderAPIResponse(id: "o1", orderNumber: "ORD-00000001", status: "processing", total: "99.99", createdAt: "2026-01-01", items: nil)
}

func makeProfile() -> UserProfile {
    UserProfile(id: "u1", firstName: "John", lastName: "Doe", email: "john@example.com", createdAt: "2026-01-01")
}

func makeNotification(id: String = "n1", isRead: Bool = false) -> AppNotification {
    AppNotification(id: id, title: "Order placed", body: "Ready", type: "order", orderId: "o1", isRead: isRead, createdAt: "2026-01-01T00:00:00Z")
}

func makeAPIResponse<T: Decodable>(_ data: T?, success: Bool = true, message: String? = nil) -> APIResponse<T> {
    APIResponse(message: message, errors: nil, data: data, success: success)
}

let networkTimeout: APIError = .networkError(URLError(.timedOut))
let noConnection: APIError   = .networkError(URLError(.notConnectedToInternet))
let serverError500: APIError = .serverError(500)
