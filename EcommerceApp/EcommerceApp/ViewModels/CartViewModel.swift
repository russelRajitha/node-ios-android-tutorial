import Foundation

@Observable
@MainActor
final class CartViewModel {
    private(set) var items: [CartItem] = []
    private(set) var isLoading: Bool = false
    private(set) var isCheckingOut: Bool = false
    private(set) var checkoutError: String? = nil

    private let cartRepository: any CartRepositoryProtocol
    private let orderRepository: any OrderRepositoryProtocol

    nonisolated init(cartRepository: any CartRepositoryProtocol, orderRepository: any OrderRepositoryProtocol) {
        self.cartRepository = cartRepository
        self.orderRepository = orderRepository
    }

    var totalPrice: Double {
        items.reduce(0) { $0 + $1.price * Double($1.quantity) }
    }

    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    func loadCart() async {
        isLoading = true
        items = await cartRepository.syncWithServer()
        isLoading = false
    }

    func increase(_ item: CartItem) {
        guard let idx = items.firstIndex(where: { $0.productId == item.productId }) else { return }
        items[idx].quantity += 1
        cartRepository.saveLocalCart(items)
    }

    func decrease(_ item: CartItem) {
        guard let idx = items.firstIndex(where: { $0.productId == item.productId }) else { return }
        if items[idx].quantity > 1 {
            items[idx].quantity -= 1
        } else {
            items.remove(at: idx)
        }
        cartRepository.saveLocalCart(items)
    }

    func remove(_ item: CartItem) {
        items.removeAll { $0.productId == item.productId }
        cartRepository.removeItem(productId: item.productId, updatedItems: items)
    }

    func checkout() async {
        isCheckingOut = true
        checkoutError = nil
        do {
            try await orderRepository.checkout()
            items = []
            cartRepository.saveLocalCart([])
        } catch let e as APIError {
            checkoutError = e.localizedDescription
        } catch {
            checkoutError = error.localizedDescription
        }
        isCheckingOut = false
    }

    func dismissCheckoutError() {
        checkoutError = nil
    }
}
