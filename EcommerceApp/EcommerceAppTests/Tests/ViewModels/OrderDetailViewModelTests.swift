import Foundation
import Testing
@testable import EcommerceApp

@MainActor
struct OrderDetailViewModelTests {

    @Test func loadOrder_success_returnsOrder() async {
        let repo = MockOrderRepository()
        repo.stubbedOrder = makeOrder()
        let vm = OrderDetailViewModel(orderRepository: repo)
        await vm.loadOrder(id: "o1")
        if case .success(let order) = vm.state {
            #expect(order.id == "o1")
        } else {
            Issue.record("Expected success state")
        }
    }

    @Test func loadOrder_apiError_setsError() async {
        let repo = MockOrderRepository()
        repo.getOrderDetailError = .apiError("Not found")
        let vm = OrderDetailViewModel(orderRepository: repo)
        await vm.loadOrder(id: "o1")
        if case .error = vm.state { } else { Issue.record("Expected error state") }
    }

    @Test func loadOrder_networkError_setsError() async {
        let repo = MockOrderRepository()
        repo.getOrderDetailError = networkTimeout
        let vm = OrderDetailViewModel(orderRepository: repo)
        await vm.loadOrder(id: "o1")
        if case .error = vm.state { } else { Issue.record("Expected error state on network timeout") }
    }
}
