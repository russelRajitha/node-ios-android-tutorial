import Foundation

enum AppRoute: Hashable {
    case configurations
    case categoryDetail(id: String, name: String)
    case productDetail(id: String)
    case orderDetail(id: String)
    case orders
}
