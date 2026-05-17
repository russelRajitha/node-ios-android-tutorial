import SwiftUI

enum AppTab: Int, CaseIterable {
    case shop
    case cart
    case notifications
    case profile

    var title: String {
        switch self {
        case .shop:          "Shop"
        case .cart:          "Cart"
        case .notifications: "Notifications"
        case .profile:       "Profile"
        }
    }

    var icon: SVGIconDefinition {
        switch self {
        case .shop:          SVGFileLoader.load(named: "tab-shop")
        case .cart:          SVGFileLoader.load(named: "tab-cart")
        case .notifications: SVGFileLoader.load(named: "tab-notifications")
        case .profile:       SVGFileLoader.load(named: "tab-person")
        }
    }
}
