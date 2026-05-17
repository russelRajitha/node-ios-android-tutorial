import Foundation
import Testing
@testable import EcommerceApp

@MainActor
struct ProductDetailViewModelTests {

    @Test func load_success_returnsProduct() async {
        let repo = MockProductRepository()
        repo.stubbedProduct = makeProduct()
        let vm = ProductDetailViewModel(repository: repo, cartRepository: MockCartRepository())
        await vm.load(productId: "p1")
        if case .success(let product) = vm.state {
            #expect(product.name == "Headphones")
        } else {
            Issue.record("Expected success state")
        }
    }

    @Test func load_apiError_setsError() async {
        let repo = MockProductRepository()
        repo.getProductError = .apiError("Not found")
        let vm = ProductDetailViewModel(repository: repo, cartRepository: MockCartRepository())
        await vm.load(productId: "p1")
        if case .error = vm.state { } else { Issue.record("Expected error state") }
    }

    @Test func load_networkError_setsError() async {
        let repo = MockProductRepository()
        repo.getProductError = networkTimeout
        let vm = ProductDetailViewModel(repository: repo, cartRepository: MockCartRepository())
        await vm.load(productId: "p1")
        if case .error = vm.state { } else { Issue.record("Expected error state on network timeout") }
    }

    @Test func addToCart_callsRepositoryAndResetsState() async {
        let cartRepo = MockCartRepository()
        let vm = ProductDetailViewModel(repository: MockProductRepository(), cartRepository: cartRepo)
        await vm.addToCart(product: makeProduct(), quantity: 2)
        #expect(cartRepo.addedProductId == "p1")
        #expect(vm.cartState == .idle)
    }
}
