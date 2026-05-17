import Foundation
import Testing
@testable import EcommerceApp

struct NotificationRepositoryTests {

    @Test func getNotifications_mapsResponseArray() async throws {
        let service = MockNotificationAPIService()
        service.stubbedNotifications = [makeNotification(), makeNotification(id: "n2")]
        let repo = NotificationRepository(apiService: service)
        let notifs = try await repo.getNotifications()
        #expect(notifs.count == 2)
    }

    @Test func getNotifications_empty_returnsEmpty() async throws {
        let service = MockNotificationAPIService()
        let repo = NotificationRepository(apiService: service)
        let notifs = try await repo.getNotifications()
        #expect(notifs.isEmpty)
    }

    @Test func markRead_delegatesToAPIService() async throws {
        let service = MockNotificationAPIService()
        let repo = NotificationRepository(apiService: service)
        try await repo.markRead(id: "n1")
        #expect(service.markedReadId == "n1")
    }

    @Test func getNotifications_networkTimeout_propagatesThrow() async throws {
        let service = MockNotificationAPIService()
        service.getNotificationsError = URLError(.timedOut)
        let repo = NotificationRepository(apiService: service)
        await #expect(throws: (any Error).self) {
            try await repo.getNotifications()
        }
    }
}
