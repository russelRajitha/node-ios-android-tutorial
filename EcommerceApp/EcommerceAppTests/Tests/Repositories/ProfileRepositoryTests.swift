import Foundation
import Testing
@testable import EcommerceApp

struct ProfileRepositoryTests {

    @Test func getProfile_success_returnsProfile() async throws {
        let service = MockUserAPIService()
        service.stubbedProfile = makeProfile()
        let repo = ProfileRepository(userAPIService: service)
        let profile = try await repo.getProfile()
        #expect(profile.email == "john@example.com")
    }

    @Test func getProfile_successFalse_throws() async throws {
        let service = MockUserAPIService()
        service.successFlag = false
        let repo = ProfileRepository(userAPIService: service)
        await #expect(throws: (any Error).self) {
            try await repo.getProfile()
        }
    }

    @Test func getProfile_nilData_throws() async throws {
        let service = MockUserAPIService()
        service.stubbedProfile = nil
        let repo = ProfileRepository(userAPIService: service)
        await #expect(throws: (any Error).self) {
            try await repo.getProfile()
        }
    }

    @Test func getProfile_noConnection_propagatesThrow() async throws {
        let service = MockUserAPIService()
        service.getProfileError = URLError(.notConnectedToInternet)
        let repo = ProfileRepository(userAPIService: service)
        await #expect(throws: (any Error).self) {
            try await repo.getProfile()
        }
    }
}
