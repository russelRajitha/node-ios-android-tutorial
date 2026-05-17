import Foundation
import SwiftData

@Model
final class CartItemModel {
    @Attribute(.unique) var productId: String
    var name: String
    var price: Double
    var quantity: Int
    var addedAt: Date
    var note: String?

    init(productId: String, name: String, price: Double, quantity: Int, addedAt: Date = Date(), note: String? = nil) {
        self.productId = productId
        self.name = name
        self.price = price
        self.quantity = quantity
        self.addedAt = addedAt
        self.note = note
    }

    func toDomain() -> CartItem {
        CartItem(productId: productId, name: name, price: price, quantity: quantity, addedAt: addedAt, note: note)
    }
}
