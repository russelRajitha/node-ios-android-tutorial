import Foundation

@Observable
@MainActor
final class ProfileViewModel {
    enum State {
        case loading
        case success(UserProfile)
        case error(String)
    }

    private(set) var state: State = .loading

    private let profileRepository: any ProfileRepositoryProtocol
    private let authRepository: any AuthRepositoryProtocol

    nonisolated init(profileRepository: any ProfileRepositoryProtocol, authRepository: any AuthRepositoryProtocol) {
        self.profileRepository = profileRepository
        self.authRepository = authRepository
    }

    func logout() async {
        await authRepository.logout()
    }

    func fetchProfile() async {
        state = .loading
        do {
            let profile = try await profileRepository.getProfile()
            state = .success(profile)
        } catch let error as APIError {
            state = .error(error.localizedDescription)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
