import Foundation

final class AuthAPIService {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func login(email: String, password: String) async throws -> APIResponse<TokenData> {
        try await networkService.request(
            endpoint: NetworkConfig.Endpoint.login,
            method: .post,
            body: LoginRequest(email: email, password: password)
        )
    }

    func refreshToken(_ refreshToken: String) async throws -> APIResponse<TokenData> {
        try await networkService.request(
            endpoint: NetworkConfig.Endpoint.refresh,
            method: .post,
            body: RefreshTokenRequest(refreshToken: refreshToken)
        )
    }

    func logout(refreshToken: String) async throws {
        let _: APIResponse<EmptyResponse> = try await networkService.request(
            endpoint: NetworkConfig.Endpoint.logout,
            method: .post,
            body: LogoutRequest(refreshToken: refreshToken)
        )
    }
}
