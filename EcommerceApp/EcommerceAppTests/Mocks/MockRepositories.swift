import Foundation
import Testing
@testable import EcommerceApp

// MARK: - Cart
final class MockCartRepository: CartRepositoryProtocol {
    var stubbedItems: [CartItem] = []
    private(set) var addedProductId: String?
    private(set) var savedItems: [CartItem]?
    private(set) var removedProductId: String?

    func syncWithServer() async -> [CartItem] { stubbedItems }
    func addToCart(productId: String, name: String, price: Double, quantity: Int) async { addedProductId = productId }
    func saveLocalCart(_ items: [CartItem]) { savedItems = items }
    func removeItem(productId: String, updatedItems: [CartItem]) { removedProductId = productId }
    func checkout() async {}
    func clearCart() {}
}

// MARK: - Order
final class MockOrderRepository: OrderRepositoryProtocol {
    var checkoutError: APIError?
    var getOrdersError: APIError?
    var getOrderDetailError: APIError?
    private(set) var checkoutCalled = false
    var stubbedOrders: [OrderAPIResponse] = []
    var stubbedOrder: OrderAPIResponse?

    func checkout() async throws {
        checkoutCalled = true
        if let err = checkoutError { throw err }
    }
    func getOrders() async throws -> [OrderAPIResponse] {
        if let err = getOrdersError { throw err }
        return stubbedOrders
    }
    func getOrderDetail(id: String) async throws -> OrderAPIResponse {
        if let err = getOrderDetailError { throw err }
        guard let order = stubbedOrder else { throw APIError.apiError("Not found") }
        return order
    }
}

// MARK: - ProductCategory
final class MockProductCategoryRepository: ProductCategoryRepositoryProtocol {
    var stubbedCategories: [ProductCategory] = []
    var stubbedCategoryDetail: CategoryDetail?
    var getCategoriesError: APIError?
    var getCategoryDetailError: APIError?

    func getCategories() async throws -> [ProductCategory] {
        if let err = getCategoriesError { throw err }
        return stubbedCategories
    }
    func getCategoryDetail(id: String) async throws -> CategoryDetail {
        if let err = getCategoryDetailError { throw err }
        guard let detail = stubbedCategoryDetail else { throw APIError.apiError("Not found") }
        return detail
    }
}

// MARK: - Notification
final class MockNotificationRepository: NotificationRepositoryProtocol {
    var stubbedNotifications: [AppNotification] = []
    var getNotificationsError: APIError?
    private(set) var markReadId: String?

    func getNotifications() async throws -> [AppNotification] {
        if let err = getNotificationsError { throw err }
        return stubbedNotifications
    }
    func markRead(id: String) async throws { markReadId = id }
}

// MARK: - Profile
final class MockProfileRepository: ProfileRepositoryProtocol {
    var stubbedProfile: UserProfile?
    var getProfileError: APIError?

    func getProfile() async throws -> UserProfile {
        if let err = getProfileError { throw err }
        guard let profile = stubbedProfile else { throw APIError.apiError("No profile") }
        return profile
    }
}

// MARK: - Auth
final class MockAuthRepository: AuthRepositoryProtocol {
    var loginError: APIError?
    private(set) var loginCalled = false
    private(set) var logoutCalled = false
    var isLoggedIn = false

    func login(email: String, password: String) async throws {
        loginCalled = true
        if let err = loginError { throw err }
    }
    func logout() async { logoutCalled = true }
}

// MARK: - Product
final class MockProductRepository: ProductRepositoryProtocol {
    var stubbedProduct: ProductDetail?
    var getProductError: APIError?

    func getProduct(id: String) async throws -> ProductDetail {
        if let err = getProductError { throw err }
        guard let product = stubbedProduct else { throw APIError.apiError("Not found") }
        return product
    }
}
