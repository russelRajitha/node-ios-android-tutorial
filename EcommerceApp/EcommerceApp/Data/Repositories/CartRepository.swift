import Foundation
import SwiftData

protocol CartRepositoryProtocol {
    func syncWithServer() async -> [CartItem]
    func addToCart(productId: String, name: String, price: Double, quantity: Int) async
    func saveLocalCart(_ items: [CartItem])
    func removeItem(productId: String, updatedItems: [CartItem])
    func checkout() async
    func clearCart()
}

final class CartRepository: CartRepositoryProtocol {
    private let context: ModelContext
    private let cartAPIService: CartAPIService

    init(context: ModelContext, cartAPIService: CartAPIService) {
        self.context = context
        self.cartAPIService = cartAPIService
        migrateFromUserDefaultsIfNeeded()
    }

    // MARK: - Protocol
    func syncWithServer() async -> [CartItem] {
        let local = fetchLocal()
        do {
            let response: APIResponse<CartAPIResponse> = try await cartAPIService.getCart()
            guard let data = response.data else { return local }

            let serverIds = Set(data.items.map { $0.productId })
            let localOnly = local.filter { !serverIds.contains($0.productId) }
            for item in localOnly {
                try? await cartAPIService.addToCart(productId: item.productId, quantity: item.quantity)
            }

            let serverItems = data.items.map { apiItem in
                CartItem(
                    productId: apiItem.productId,
                    name: apiItem.product.name,
                    price: Double(apiItem.product.price) ?? 0,
                    quantity: apiItem.quantity
                )
            }
            persist(serverItems + localOnly)
            return fetchLocal()
        } catch {
            return local
        }
    }

    func addToCart(productId: String, name: String, price: Double, quantity: Int) async {
        let descriptor = FetchDescriptor<CartItemModel>(predicate: #Predicate { $0.productId == productId })
        if let existing = try? context.fetch(descriptor).first {
            existing.quantity += quantity
        } else {
            context.insert(CartItemModel(productId: productId, name: name, price: price, quantity: quantity))
        }
        try? context.save()
        Task { try? await cartAPIService.addToCart(productId: productId, quantity: quantity) }
    }

    func saveLocalCart(_ items: [CartItem]) {
        persist(items)
    }

    func removeItem(productId: String, updatedItems: [CartItem]) {
        let descriptor = FetchDescriptor<CartItemModel>(predicate: #Predicate { $0.productId == productId })
        if let model = try? context.fetch(descriptor).first {
            context.delete(model)
        }
        try? context.save()
        Task { try? await cartAPIService.removeFromCart(productId: productId) }
    }

    func checkout() async {
        fetchAllModels().forEach { context.delete($0) }
        try? context.save()
    }

    func clearCart() {
        saveLocalCart([])
    }

    // MARK: - Private

    private func fetchLocal() -> [CartItem] {
        fetchAllModels().map { $0.toDomain() }
    }

    private func fetchAllModels() -> [CartItemModel] {
        (try? context.fetch(FetchDescriptor<CartItemModel>())) ?? []
    }

    /// Upserts `items` into the store and deletes any model whose productId is not in the new list.
    private func persist(_ items: [CartItem]) {
        let existing = fetchAllModels()
        let newIds = Set(items.map { $0.productId })
        existing.filter { !newIds.contains($0.productId) }.forEach { context.delete($0) }

        let existingById = Dictionary(uniqueKeysWithValues: existing.map { ($0.productId, $0) })
        for item in items {
            if let model = existingById[item.productId] {
                model.quantity = item.quantity
                model.name = item.name
                model.price = item.price
                model.note = item.note
            } else {
                context.insert(CartItemModel(
                    productId: item.productId,
                    name: item.name,
                    price: item.price,
                    quantity: item.quantity,
                    addedAt: item.addedAt,
                    note: item.note
                ))
            }
        }
        try? context.save()
    }

    // MARK: - One-time migration: CartStore v3 JSON (UserDefaults) → SwiftData

    private func migrateFromUserDefaultsIfNeeded() {
        let flag = "cart_swiftdata_migrated"
        guard !UserDefaults.standard.bool(forKey: flag) else { return }
        defer { UserDefaults.standard.set(true, forKey: flag) }

        guard let data = UserDefaults.standard.data(forKey: "cart_items"),
              let legacy = try? JSONDecoder().decode([LegacyCartItem].self, from: data) else { return }

        for item in legacy {
            context.insert(CartItemModel(
                productId: item.productId,
                name: item.name,
                price: item.price,
                quantity: item.quantity,
                addedAt: item.addedAt ?? Date(),
                note: item.note
            ))
        }
        try? context.save()
        UserDefaults.standard.removeObject(forKey: "cart_items")
        UserDefaults.standard.removeObject(forKey: "cart_store_version")
    }
}

/// Mirrors the on-disk JSON written by CartStore v1–v3. Used only during one-time migration.
private struct LegacyCartItem: Codable {
    let productId: String
    let name: String
    let price: Double
    let quantity: Int
    var addedAt: Date?
    var note: String?
}
