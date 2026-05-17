import Foundation
import Testing
@testable import EcommerceApp

@MainActor
struct NotificationsViewModelTests {

    @Test func loadNotifications_success_returnsNotifications() async {
        let repo = MockNotificationRepository()
        repo.stubbedNotifications = [makeNotification(), makeNotification(id: "n2")]
        let vm = NotificationsViewModel(notificationRepository: repo)
        await vm.loadNotifications()
        if case .success(let notifs) = vm.state {
            #expect(notifs.count == 2)
        } else {
            Issue.record("Expected success state")
        }
    }

    @Test func loadNotifications_apiError_setsError() async {
        let repo = MockNotificationRepository()
        repo.getNotificationsError = .apiError("Network error")
        let vm = NotificationsViewModel(notificationRepository: repo)
        await vm.loadNotifications()
        if case .error = vm.state { } else { Issue.record("Expected error state") }
    }

    @Test func loadNotifications_networkError_setsError() async {
        let repo = MockNotificationRepository()
        repo.getNotificationsError = networkTimeout
        let vm = NotificationsViewModel(notificationRepository: repo)
        await vm.loadNotifications()
        if case .error = vm.state { } else { Issue.record("Expected error state on network timeout") }
    }

    @Test func markRead_alreadyRead_skipsAPICall() async {
        let repo = MockNotificationRepository()
        let vm = NotificationsViewModel(notificationRepository: repo)
        await vm.markRead(makeNotification(isRead: true))
        #expect(repo.markReadId == nil)
    }

    @Test func markRead_unread_callsAPIAndReloads() async {
        let repo = MockNotificationRepository()
        repo.stubbedNotifications = [makeNotification()]
        let vm = NotificationsViewModel(notificationRepository: repo)
        await vm.markRead(makeNotification(isRead: false))
        #expect(repo.markReadId == "n1")
        if case .success = vm.state { } else { Issue.record("Expected success after reload") }
    }
}
