import Foundation

@Observable @MainActor final class ProductDetailViewModel {
    enum State {
        case idle
        case loading
        case success(ProductDetail)
        case error(String)
    }

    enum CartState: Equatable {
        case idle, loading, success, error(String)
    }

    private(set) var state: State = .idle
    private(set) var cartState: CartState = .idle

    private let repository: any ProductRepositoryProtocol
    private let cartRepository: any CartRepositoryProtocol

    nonisolated init(repository: any ProductRepositoryProtocol, cartRepository: any CartRepositoryProtocol) {
        self.repository = repository
        self.cartRepository = cartRepository
    }

    func load(productId: String) async {
        state = .loading
        do {
            state = .success(try await repository.getProduct(id: productId))
        } catch let e as APIError {
            state = .error(e.localizedDescription)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func addToCart(product: ProductDetail, quantity: Int = 1) async {
        guard cartState == .idle else { return }
        cartState = .loading
        await cartRepository.addToCart(
            productId: product.id,
            name: product.name,
            price: Double(product.price) ?? 0,
            quantity: quantity
        )
        cartState = .success
        try? await Task.sleep(for: .seconds(2))
        cartState = .idle
    }
}
