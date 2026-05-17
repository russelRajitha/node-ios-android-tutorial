import Foundation
import Testing
@testable import EcommerceApp

@MainActor
struct CartViewModelTests {

    private func makeVM(
        items: [CartItem] = [],
        checkoutError: APIError? = nil
    ) -> (CartViewModel, MockCartRepository, MockOrderRepository) {
        let cartRepo = MockCartRepository()
        cartRepo.stubbedItems = items
        let orderRepo = MockOrderRepository()
        orderRepo.checkoutError = checkoutError
        return (CartViewModel(cartRepository: cartRepo, orderRepository: orderRepo), cartRepo, orderRepo)
    }

    @Test func loadsItemsFromRepository() async {
        let (vm, _, _) = makeVM(items: [makeCart("p1"), makeCart("p2")])
        await vm.loadCart()
        #expect(vm.items.count == 2)
        #expect(!vm.isLoading)
    }

    @Test func loadCart_emptyRepository_returnsEmpty() async {
        let (vm, _, _) = makeVM()
        await vm.loadCart()
        #expect(vm.items.isEmpty)
    }

    @Test func totalPriceCalculation() async {
        let (vm, _, _) = makeVM(items: [
            makeCart("p1", price: 10.00, qty: 3),
            makeCart("p2", price: 20.00, qty: 2),
        ])
        await vm.loadCart()
        #expect(vm.totalPrice == 70.00)
    }

    @Test func totalItemsCalculation() async {
        let (vm, _, _) = makeVM(items: [makeCart("p1", qty: 3), makeCart("p2", qty: 2)])
        await vm.loadCart()
        #expect(vm.totalItems == 5)
    }

    @Test func increaseQuantity() async {
        let (vm, _, _) = makeVM(items: [makeCart("p1", qty: 1)])
        await vm.loadCart()
        vm.increase(vm.items[0])
        #expect(vm.items[0].quantity == 2)
    }

    @Test func decreaseQuantityAboveOne() async {
        let (vm, _, _) = makeVM(items: [makeCart("p1", qty: 2)])
        await vm.loadCart()
        vm.decrease(vm.items[0])
        #expect(vm.items[0].quantity == 1)
    }

    @Test func decreaseBelowOneRemovesItem() async {
        let (vm, _, _) = makeVM(items: [makeCart("p1", qty: 1)])
        await vm.loadCart()
        vm.decrease(vm.items[0])
        #expect(vm.items.isEmpty)
    }

    @Test func removeItem() async {
        let (vm, _, _) = makeVM(items: [makeCart("p1"), makeCart("p2")])
        await vm.loadCart()
        vm.remove(vm.items[0])
        #expect(vm.items.count == 1)
        #expect(vm.items[0].productId == "p2")
    }

    @Test func checkout_success_clearsCart() async {
        let (vm, cartRepo, orderRepo) = makeVM(items: [makeCart()])
        await vm.loadCart()
        await vm.checkout()
        #expect(vm.items.isEmpty)
        #expect(orderRepo.checkoutCalled)
        #expect(cartRepo.savedItems?.isEmpty == true)
        #expect(!vm.isCheckingOut)
        #expect(vm.checkoutError == nil)
    }

    @Test func checkout_apiError_keepsCartAndSetsError() async {
        let (vm, _, _) = makeVM(items: [makeCart()], checkoutError: .apiError("Payment failed"))
        await vm.loadCart()
        await vm.checkout()
        #expect(vm.checkoutError != nil)
        #expect(!vm.items.isEmpty)
        #expect(!vm.isCheckingOut)
    }

    @Test func checkout_networkError_keepsCartAndSetsError() async {
        let (vm, _, _) = makeVM(items: [makeCart()], checkoutError: networkTimeout)
        await vm.loadCart()
        await vm.checkout()
        #expect(vm.checkoutError != nil)
        #expect(!vm.items.isEmpty)
    }

    @Test func dismissCheckoutError_clearsError() async {
        let (vm, _, _) = makeVM(checkoutError: .apiError("Failed"))
        await vm.loadCart()
        await vm.checkout()
        vm.dismissCheckoutError()
        #expect(vm.checkoutError == nil)
    }
}
