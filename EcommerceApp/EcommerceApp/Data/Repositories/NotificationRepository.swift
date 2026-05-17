import Foundation

protocol NotificationRepositoryProtocol {
    func getNotifications() async throws -> [AppNotification]
    func markRead(id: String) async throws
}

final class NotificationRepository: NotificationRepositoryProtocol {
    private let apiService: any NotificationAPIServiceProtocol

    init(apiService: any NotificationAPIServiceProtocol) {
        self.apiService = apiService
    }

    func getNotifications() async throws -> [AppNotification] {
        let response = try await apiService.getNotifications()
        return response.data ?? []
    }

    func markRead(id: String) async throws {
        try await apiService.markRead(id: id)
    }
}
