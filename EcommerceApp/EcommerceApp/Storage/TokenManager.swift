import Combine
import Foundation
import Security

private actor TokenStorage {
    private(set) var sessionExpirySent = false

    func markExpirySent() -> Bool {
        guard !sessionExpirySent else { return false }
        sessionExpirySent = true
        return true
    }

    func resetExpiry() {
        sessionExpirySent = false
    }
}

final class TokenManager: @unchecked Sendable {
    private let storage = TokenStorage()
    private let service = Bundle.main.bundleIdentifier ?? "com.ecommerce.app"

    private let accessKey = "access_token"
    private let refreshKey = "refresh_token"
    private let refreshAttemptKey = "auth_refresh_attempt_count"

    let sessionExpiredPublisher = PassthroughSubject<Void, Never>()

    let loginSuccessPublisher = PassthroughSubject<Void, Never>()

    init() {
        migrateFromUserDefaultsIfNeeded()
    }

    // MARK: - Read
    var accessToken: String? { keychainRead(key: accessKey) }
    var refreshToken: String? { keychainRead(key: refreshKey) }
    var isLoggedIn: Bool { accessToken != nil }

    // MARK: - Refresh attempt counter (persists across app restarts)
    var refreshAttemptCount: Int {
        UserDefaults.standard.integer(forKey: refreshAttemptKey)
    }

    func incrementRefreshAttemptCount() {
        UserDefaults.standard.set(refreshAttemptCount + 1, forKey: refreshAttemptKey)
    }

    func resetRefreshAttemptCount() {
        UserDefaults.standard.set(0, forKey: refreshAttemptKey)
    }

    // MARK: - Write
    func saveTokens(access: String, refresh: String) {
        keychainWrite(value: access, key: accessKey)
        keychainWrite(value: refresh, key: refreshKey)
        Task { await storage.resetExpiry() }
        loginSuccessPublisher.send()
    }

    func clearTokens() {
        keychainDelete(key: accessKey)
        keychainDelete(key: refreshKey)
        resetRefreshAttemptCount()
    }

    func clearTokensAndSignalExpiry() {
        keychainDelete(key: accessKey)
        keychainDelete(key: refreshKey)
        Task { [weak self] in
            guard let self else { return }
            guard await storage.markExpirySent() else { return }
            await MainActor.run { self.sessionExpiredPublisher.send() }
        }
    }

    // MARK: - Keychain
    private func keychainWrite(value: String, key: String) {
        let data = Data(value.utf8)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
        ]
        let status = SecItemUpdate(query as CFDictionary, [kSecValueData: data] as CFDictionary)
        if status == errSecItemNotFound {
            var attributes = query
            attributes[kSecValueData] = data
            attributes[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            SecItemAdd(attributes as CFDictionary, nil)
        }
    }

    private func keychainRead(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func keychainDelete(key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - One-time migration from UserDefaults
    private func migrateFromUserDefaultsIfNeeded() {
        let migrationKey = "token_keychain_migrated"
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }
        defer { UserDefaults.standard.set(true, forKey: migrationKey) }

        if let access = UserDefaults.standard.string(forKey: accessKey) {
            keychainWrite(value: access, key: accessKey)
            UserDefaults.standard.removeObject(forKey: accessKey)
        }
        if let refresh = UserDefaults.standard.string(forKey: refreshKey) {
            keychainWrite(value: refresh, key: refreshKey)
            UserDefaults.standard.removeObject(forKey: refreshKey)
        }
    }
}
