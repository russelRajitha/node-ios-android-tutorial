import Foundation

protocol ProfileRepositoryProtocol {
    func getProfile() async throws -> UserProfile
}

final class ProfileRepository: ProfileRepositoryProtocol {
    private let userAPIService: any UserAPIServiceProtocol

    init(userAPIService: any UserAPIServiceProtocol) {
        self.userAPIService = userAPIService
    }

    func getProfile() async throws -> UserProfile {
        let response = try await userAPIService.getProfile()
        guard response.success, let profile = response.data else {
            throw APIError.apiError(response.message ?? "Failed to load profile")
        }
        return profile
    }
}
