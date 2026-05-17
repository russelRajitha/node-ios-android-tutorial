import Foundation

struct CartItem: Codable, Identifiable {
    var id: String { productId }
    let productId: String
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
}
