import Foundation

@Observable
@MainActor
final class LoginViewModel {
    enum State: Equatable {
        case idle
        case loading
        case success
        case error(message: String, fieldErrors: [String: [String]]?)
    }

    private(set) var state: State = .idle

    private let authRepository: any AuthRepositoryProtocol

    nonisolated init(authRepository: any AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func login(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            state = .error(message: "Email and password are required", fieldErrors: nil)
            return
        }
        state = .loading
        do {
            try await authRepository.login(email: email, password: password)
            state = .success
        } catch let error as APIError {
            if case .validationError(let msg, let fieldErrors) = error {
                state = .error(message: msg, fieldErrors: fieldErrors)
            } else {
                state = .error(message: error.localizedDescription, fieldErrors: nil)
            }
        } catch {
            state = .error(message: error.localizedDescription, fieldErrors: nil)
        }
    }

    func clearError() {
        state = .idle
    }
}
