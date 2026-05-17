import Foundation

final class DeviceTokenRepository {
    private let apiService: DeviceTokenAPIService

    init(apiService: DeviceTokenAPIService) {
        self.apiService = apiService
    }

    func register() async throws {
        guard let token = UserDefaults.standard.string(forKey: "fcm_device_token") else { return }
        try await apiService.register(token: token, platform: "ios")
    }

    func unregister() async throws {
        guard let token = UserDefaults.standard.string(forKey: "fcm_device_token") else { return }
        try await apiService.unregister(token: token)
    }
}
