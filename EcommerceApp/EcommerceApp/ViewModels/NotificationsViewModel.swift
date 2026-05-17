import Foundation

@Observable
@MainActor
final class NotificationsViewModel {
    enum State {
        case idle, loading, success([AppNotification]), error(String)
    }

    private(set) var state: State = .idle

    private let notificationRepository: any NotificationRepositoryProtocol

    nonisolated init(notificationRepository: any NotificationRepositoryProtocol) {
        self.notificationRepository = notificationRepository
    }

    func loadNotifications() async {
        state = .loading
        do {
            let notifications = try await notificationRepository.getNotifications()
            state = .success(notifications)
        } catch let e as APIError {
            state = .error(e.localizedDescription)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func markRead(_ notification: AppNotification) async {
        guard !notification.isRead else { return }
        try? await notificationRepository.markRead(id: notification.id)
        await loadNotifications()
    }
}
