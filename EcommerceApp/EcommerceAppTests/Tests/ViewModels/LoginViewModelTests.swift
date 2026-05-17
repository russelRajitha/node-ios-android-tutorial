import Foundation
import Testing
@testable import EcommerceApp

@MainActor
struct LoginViewModelTests {

    private func makeVM(loginError: APIError? = nil) -> (LoginViewModel, MockAuthRepository) {
        let repo = MockAuthRepository()
        repo.loginError = loginError
        return (LoginViewModel(authRepository: repo), repo)
    }

    @Test func login_emptyEmail_setsError_withoutCallingRepository() async {
        let (vm, repo) = makeVM()
        await vm.login(email: "", password: "password")
        if case .error = vm.state { } else { Issue.record("Expected error state") }
        #expect(!repo.loginCalled)
    }

    @Test func login_emptyPassword_setsError_withoutCallingRepository() async {
        let (vm, repo) = makeVM()
        await vm.login(email: "test@test.com", password: "")
        if case .error = vm.state { } else { Issue.record("Expected error state") }
        #expect(!repo.loginCalled)
    }

    @Test func login_success_setsSuccessState() async {
        let (vm, _) = makeVM()
        await vm.login(email: "test@test.com", password: "password")
        #expect(vm.state == .success)
    }

    @Test func login_apiError_setsErrorMessage() async {
        let (vm, _) = makeVM(loginError: .apiError("Invalid credentials"))
        await vm.login(email: "test@test.com", password: "password")
        if case .error(let msg, _) = vm.state {
            #expect(msg.contains("Invalid credentials"))
        } else {
            Issue.record("Expected error state")
        }
    }

    @Test func login_validationError_exposesFieldErrors() async {
        let (vm, _) = makeVM(loginError: .validationError(
            message: "Validation failed",
            fieldErrors: ["email": ["must be a valid email"]]
        ))
        await vm.login(email: "bad-email", password: "password")
        if case .error(let msg, let fields) = vm.state {
            #expect(msg == "Validation failed")
            #expect(fields?["email"]?.first == "must be a valid email")
        } else {
            Issue.record("Expected validationError state")
        }
    }

    @Test func clearError_resetsToIdle() async {
        let (vm, _) = makeVM(loginError: .apiError("Fail"))
        await vm.login(email: "test@test.com", password: "password")
        vm.clearError()
        #expect(vm.state == .idle)
    }
}
