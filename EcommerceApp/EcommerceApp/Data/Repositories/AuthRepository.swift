import Foundation

protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws
    func logout() async
    var isLoggedIn: Bool { get }
}

final class AuthRepository: AuthRepositoryProtocol {
    private let authAPIService: AuthAPIService
    private let tokenManager: TokenManager
    private let deviceTokenRepository: DeviceTokenRepository
    private let cartRepository: any CartRepositoryProtocol

    init(
        authAPIService: AuthAPIService,
        tokenManager: TokenManager,
        deviceTokenRepository: DeviceTokenRepository,
        cartRepository: any CartRepositoryProtocol
    ) {
        self.authAPIService = authAPIService
        self.tokenManager = tokenManager
        self.deviceTokenRepository = deviceTokenRepository
        self.cartRepository = cartRepository
    }

    func login(email: String, password: String) async throws {
        let response = try await authAPIService.login(email: email, password: password)
        guard response.success, let tokenData = response.data else {
            throw APIError.apiError(response.message ?? "Login failed")
        }
        guard let refreshToken = tokenData.refreshToken else {
            throw APIError.apiError("No refresh token received from server")
        }
        tokenManager.saveTokens(access: tokenData.accessToken, refresh: refreshToken)
        tokenManager.resetRefreshAttemptCount()
        Task { try? await deviceTokenRepository.register() }
    }

    func logout() async {
        try? await deviceTokenRepository.unregister()
        if let token = tokenManager.refreshToken {
            try? await authAPIService.logout(refreshToken: token)
        }
        tokenManager.clearTokens()
        cartRepository.clearCart()
    }

    var isLoggedIn: Bool {
        tokenManager.isLoggedIn
    }
}
