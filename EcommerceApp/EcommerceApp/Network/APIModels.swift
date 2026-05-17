import Foundation

// MARK: - Generic API Envelope
struct APIResponse<T: Decodable>: Decodable {
    let message: String?
    let errors: [String: [String]]?   // server sends {} or { "field": ["msg"] }
    let data: T?
    let success: Bool
}

// MARK: - Token
struct TokenData: Decodable {
    let accessToken: String
    let refreshToken: String?
}

// MARK: - User Profile
struct UserProfile: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let createdAt: String
}

// MARK: - Requests
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

struct LogoutRequest: Encodable {
    let refreshToken: String
}

struct EmptyResponse: Decodable {}

// MARK: - Product Categories
struct ProductCategory: Decodable, Identifiable {
    let id: String
    let name: String
    let icon: String
}

struct CategoriesResponse: Decodable {
    let categories: [ProductCategory]
}

// MARK: - Category Detail
struct CategoryProduct: Decodable, Identifiable {
    let id: String
    let name: String
    let price: String
    let image: String
}

struct CategoryDetail: Decodable {
    let category: ProductCategory
    let products: [CategoryProduct]
    let count: Int
}

// MARK: - Product Detail
struct ProductImage: Decodable, Identifiable {
    let id: String
    let image: String
}

struct ProductDetail: Decodable, Identifiable {
    let id: String
    let name: String
    let description: String
    let image: String?
    let price: String
    let brand: String
    let stock: Int
    let category: ProductCategory?
    let images: [ProductImage]
}

struct ProductDetailResponse: Decodable {
    let product: ProductDetail
}

// MARK: - Cart API
struct CartAPIProduct: Decodable {
    let id: String
    let name: String
    let price: String
    let image: String
    let brand: String
    let stock: Int
}

struct CartAPIItem: Decodable {
    let productId: String
    let quantity: Int
    let product: CartAPIProduct
}

struct CartAPIResponse: Decodable {
    let items: [CartAPIItem]
    let totalItems: Int
    let totalPrice: Double
}

struct AddToCartRequest: Encodable {
    let productId: String
    let quantity: Int
}

// MARK: - Orders API
struct OrderAPIItem: Decodable, Identifiable {
    let id: String
    let productId: String?
    let productName: String
    let productImage: String?
    let productPrice: String
    let quantity: Int
}

struct OrderAPIResponse: Decodable, Identifiable {
    let id: String
    let orderNumber: String
    let status: String
    let total: String
    let createdAt: String
    let items: [OrderAPIItem]?
}

// MARK: - Notifications API
struct AppNotification: Decodable, Identifiable {
    let id: String
    let title: String
    let body: String
    let type: String
    let orderId: String?
    let isRead: Bool
    let createdAt: String
}