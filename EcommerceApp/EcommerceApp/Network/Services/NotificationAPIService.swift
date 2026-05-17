import Foundation

protocol NotificationAPIServiceProtocol {
    func getNotifications() async throws -> APIResponse<[AppNotification]>
    func markRead(id: String) async throws
}

final class NotificationAPIService: NotificationAPIServiceProtocol {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getNotifications() async throws -> APIResponse<[AppNotification]> {
        try await networkService.authenticatedRequest(endpoint: NetworkConfig.Endpoint.notifications)
    }

    func markRead(id: String) async throws {
        let _: APIResponse<EmptyResponse> = try await networkService.authenticatedRequest(
            endpoint: NetworkConfig.Endpoint.notificationRead(id: id),
            method: .patch
        )
    }
}
