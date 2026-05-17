import Foundation
import Testing
@testable import EcommerceApp

@MainActor
struct ProfileViewModelTests {

    @Test func fetchProfile_success_returnsProfile() async {
        let profileRepo = MockProfileRepository()
        profileRepo.stubbedProfile = makeProfile()
        let vm = ProfileViewModel(profileRepository: profileRepo, authRepository: MockAuthRepository())
        await vm.fetchProfile()
        if case .success(let profile) = vm.state {
            #expect(profile.firstName == "John")
            #expect(profile.email == "john@example.com")
        } else {
            Issue.record("Expected success state")
        }
    }

    @Test func fetchProfile_apiError_setsError() async {
        let profileRepo = MockProfileRepository()
        profileRepo.getProfileError = .apiError("Failed to load profile")
        let vm = ProfileViewModel(profileRepository: profileRepo, authRepository: MockAuthRepository())
        await vm.fetchProfile()
        if case .error = vm.state { } else { Issue.record("Expected error state") }
    }

    @Test func fetchProfile_unauthorized_setsErrorUniformly() async {
        let profileRepo = MockProfileRepository()
        profileRepo.getProfileError = .unauthorized
        let vm = ProfileViewModel(profileRepository: profileRepo, authRepository: MockAuthRepository())
        await vm.fetchProfile()
        if case .error = vm.state { } else { Issue.record("Expected generic error state for .unauthorized") }
    }

    @Test func logout_callsAuthRepository() async {
        let authRepo = MockAuthRepository()
        let vm = ProfileViewModel(profileRepository: MockProfileRepository(), authRepository: authRepo)
        await vm.logout()
        #expect(authRepo.logoutCalled)
    }
}
