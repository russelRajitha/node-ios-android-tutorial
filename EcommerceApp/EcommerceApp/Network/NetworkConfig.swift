import Foundation
import Alamofire

enum NetworkConfig {
    static let baseURL = "http://localhost:4000"

    enum Endpoint {
        static let login = "/api/auth/login"
        static let refresh = "/api/auth/refresh"
        static let logout = "/api/auth/logout"
        static let profile = "/api/user/profile"
        static let productCategories = "/api/product-categories/all"
        static func productCategory(id: String) -> String { "/api/product-categories/\(id)" }
        static func product(id: String) -> String { "/api/products/\(id)" }
        static let cart = "/api/cart"
        static let cartAdd = "/api/cart/add"
        static let ordersCheckout = "/api/orders/checkout"
        static let orders = "/api/orders"
        static func order(id: String) -> String { "/api/orders/\(id)" }
        static let notifications = "/api/notifications"
        static func notificationRead(id: String) -> String { "/api/notifications/\(id)/read" }
        static let deviceTokens = "/api/device-tokens"
    }

    enum Timeout {
        static let standard: TimeInterval = 30
        static let fileUpload: TimeInterval = 120
    }
}

typealias HTTPMethod = Alamofire.HTTPMethod
