import Foundation

protocol UserAPIServiceProtocol {
    func getProfile() async throws -> APIResponse<UserProfile>
}

final class UserAPIService: UserAPIServiceProtocol {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getProfile() async throws -> APIResponse<UserProfile> {
        try await networkService.authenticatedRequest(
            endpoint: NetworkConfig.Endpoint.profile,
            method: .get
        )
    }
}
