import Foundation
import Testing
@testable import EcommerceApp

// MARK: - ProductCategory
final class MockProductCategoryAPIService: ProductCategoryAPIServiceProtocol {
    var stubbedCategories: [ProductCategory] = []
    var stubbedCategoryDetail: CategoryDetail?
    var getCategoriesError: Error?
    var getCategoryDetailError: Error?

    func getCategories() async throws -> APIResponse<CategoriesResponse> {
        if let err = getCategoriesError { throw err }
        return makeAPIResponse(CategoriesResponse(categories: stubbedCategories))
    }
    func getCategoryDetail(id: String) async throws -> APIResponse<CategoryDetail> {
        if let err = getCategoryDetailError { throw err }
        return makeAPIResponse(stubbedCategoryDetail)
    }
}

// MARK: - User

final class MockUserAPIService: UserAPIServiceProtocol {
    var stubbedProfile: UserProfile?
    var successFlag = true
    var getProfileError: Error?

    func getProfile() async throws -> APIResponse<UserProfile> {
        if let err = getProfileError { throw err }
        return makeAPIResponse(stubbedProfile, success: successFlag, message: successFlag ? nil : "Error")
    }
}

// MARK: - Product

final class MockProductAPIService: ProductAPIServiceProtocol {
    var stubbedProduct: ProductDetail?
    var getProductError: Error?

    func getProduct(id: String) async throws -> APIResponse<ProductDetailResponse> {
        if let err = getProductError { throw err }
        let wrapper = stubbedProduct.map { ProductDetailResponse(product: $0) }
        return makeAPIResponse(wrapper)
    }
}

// MARK: - Notification

final class MockNotificationAPIService: NotificationAPIServiceProtocol {
    var stubbedNotifications: [AppNotification] = []
    var getNotificationsError: Error?
    private(set) var markedReadId: String?

    func getNotifications() async throws -> APIResponse<[AppNotification]> {
        if let err = getNotificationsError { throw err }
        return makeAPIResponse(stubbedNotifications)
    }
    func markRead(id: String) async throws { markedReadId = id }
}

// MARK: - Order
final class MockOrderAPIService: OrderAPIServiceProtocol {
    var stubbedOrders: [OrderAPIResponse] = []
    var stubbedOrder: OrderAPIResponse?
    var checkoutSuccessFlag = true
    var checkoutError: Error?
    var getOrderDetailError: Error?

    func checkout() async throws -> APIResponse<OrderAPIResponse> {
        if let err = checkoutError { throw err }
        return makeAPIResponse(stubbedOrder, success: checkoutSuccessFlag, message: checkoutSuccessFlag ? nil : "Checkout failed")
    }
    func getOrders() async throws -> APIResponse<[OrderAPIResponse]> {
        makeAPIResponse(stubbedOrders)
    }
    func getOrderDetail(id: String) async throws -> APIResponse<OrderAPIResponse> {
        if let err = getOrderDetailError { throw err }
        return makeAPIResponse(stubbedOrder)
    }
}
