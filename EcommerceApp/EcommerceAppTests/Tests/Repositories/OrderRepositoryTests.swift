import Foundation
import Testing
@testable import EcommerceApp

struct OrderRepositoryTests {

    @Test func getOrders_mapsResponseArray() async throws {
        let service = MockOrderAPIService()
        service.stubbedOrders = [makeOrder()]
        let repo = OrderRepository(apiService: service)
        let orders = try await repo.getOrders()
        #expect(orders.count == 1)
        #expect(orders[0].orderNumber == "ORD-00000001")
    }

    @Test func getOrderDetail_success_returnsOrder() async throws {
        let service = MockOrderAPIService()
        service.stubbedOrder = makeOrder()
        let repo = OrderRepository(apiService: service)
        let order = try await repo.getOrderDetail(id: "o1")
        #expect(order.id == "o1")
    }

    @Test func getOrderDetail_nilData_throws() async throws {
        let service = MockOrderAPIService()
        service.stubbedOrder = nil
        let repo = OrderRepository(apiService: service)
        await #expect(throws: (any Error).self) {
            try await repo.getOrderDetail(id: "o1")
        }
    }

    @Test func checkout_successFalse_throws() async throws {
        let service = MockOrderAPIService()
        service.checkoutSuccessFlag = false
        let repo = OrderRepository(apiService: service)
        await #expect(throws: (any Error).self) {
            try await repo.checkout()
        }
    }

    @Test func getOrderDetail_networkTimeout_propagatesThrow() async throws {
        let service = MockOrderAPIService()
        service.getOrderDetailError = URLError(.timedOut)
        let repo = OrderRepository(apiService: service)
        await #expect(throws: (any Error).self) {
            try await repo.getOrderDetail(id: "o1")
        }
    }
}
