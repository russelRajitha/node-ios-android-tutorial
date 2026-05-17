import Foundation

private struct RegisterTokenBody: Encodable {
    let token: String
    let platform: String
}

private struct UnregisterTokenBody: Encodable {
    let token: String
}

final class DeviceTokenAPIService {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func register(token: String, platform: String) async throws {
        let body = RegisterTokenBody(token: token, platform: platform)
        let _: APIResponse<EmptyResponse> = try await networkService.authenticatedRequest(
            endpoint: NetworkConfig.Endpoint.deviceTokens,
            method: .post,
            body: body
        )
    }

    func unregister(token: String) async throws {
        let body = UnregisterTokenBody(token: token)
        let _: APIResponse<EmptyResponse> = try await networkService.authenticatedRequest(
            endpoint: NetworkConfig.Endpoint.deviceTokens,
            method: .delete,
            body: body
        )
    }
}
