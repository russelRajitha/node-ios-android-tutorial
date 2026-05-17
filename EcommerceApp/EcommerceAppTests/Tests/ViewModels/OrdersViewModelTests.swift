import Foundation
import Testing
@testable import EcommerceApp

@MainActor
struct OrdersViewModelTests {

    @Test func loadOrders_success_returnsOrders() async {
        let repo = MockOrderRepository()
        repo.stubbedOrders = [makeOrder()]
        let vm = OrdersViewModel(orderRepository: repo)
        await vm.loadOrders()
        if case .success(let orders) = vm.state {
            #expect(orders.count == 1)
            #expect(orders[0].orderNumber == "ORD-00000001")
        } else {
            Issue.record("Expected success state")
        }
    }

    @Test func loadOrders_apiError_setsError() async {
        let repo = MockOrderRepository()
        repo.getOrdersError = .apiError("Server error")
        let vm = OrdersViewModel(orderRepository: repo)
        await vm.loadOrders()
        if case .error = vm.state { } else { Issue.record("Expected error state") }
    }

    @Test func loadOrders_serverError_setsError() async {
        let repo = MockOrderRepository()
        repo.getOrdersError = serverError500
        let vm = OrdersViewModel(orderRepository: repo)
        await vm.loadOrders()
        if case .error = vm.state { } else { Issue.record("Expected error state on server 500") }
    }
}
