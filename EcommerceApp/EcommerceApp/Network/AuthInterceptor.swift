import Alamofire
import Combine
import Foundation

final class AuthInterceptor: RequestInterceptor, @unchecked Sendable {

    private let tokenManager: TokenManager
    private let refreshSession: Session

    private let maxRefreshAttempts = 3

    private let lock = NSLock()
    private var isRefreshing = false

    private var pendingRetryCompletions: [(RetryResult) -> Void] = []

    private var pendingAdaptCompletions: [(URLRequest, (Result<URLRequest, Error>) -> Void)] = []

    private var postLoginQueue: [(RetryResult) -> Void] = []

    private var cancellables = Set<AnyCancellable>()

    init(tokenManager: TokenManager, refreshSession: Session) {
        self.tokenManager = tokenManager
        self.refreshSession = refreshSession
        subscribeToLoginSuccess()
    }

    private func subscribeToLoginSuccess() {
        tokenManager.loginSuccessPublisher
            .receive(on: DispatchQueue.global())
            .sink { [weak self] in self?.flushPostLoginQueue() }
            .store(in: &cancellables)
    }

    private func flushPostLoginQueue() {
        lock.lock()
        let queued = postLoginQueue
        postLoginQueue = []
        lock.unlock()
        guard !queued.isEmpty else { return }
        log("loginSuccess → retrying \(queued.count) post-expiry request(s)")
        queued.forEach { $0(.retry) }
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        guard let token = tokenManager.accessToken else {
            log("adapt → no access token, sending request unauthenticated")
            completion(.success(urlRequest))
            return
        }

        if isTokenExpiredOrExpiringSoon(token),
           tokenManager.refreshToken != nil,
           tokenManager.refreshAttemptCount < maxRefreshAttempts {

            lock.lock()
            if isRefreshing {
                log("adapt → token expiring soon, refresh in-flight — queuing adapt")
                pendingAdaptCompletions.append((urlRequest, completion))
                lock.unlock()
                return
            }
            isRefreshing = true
            lock.unlock()

            log("adapt → token expiring soon, triggering proactive refresh")
            performRefresh { [weak self] success in
                guard let self else { return }
                self.flushAfterRefresh(
                    success: success,
                    originalRequest: urlRequest,
                    adaptCompletion: completion
                )
            }
            return
        }

        var request = urlRequest
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let preview = String(token.suffix(8))
        log("adapt → attaching token …\(preview) to \(request.httpMethod ?? "?") \(request.url?.path ?? "")")
        completion(.success(request))
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        let statusCode = request.response?.statusCode ?? -1
        guard statusCode == 401 else {
            log("retry → skipping (HTTP \(statusCode))")
            completion(.doNotRetry)
            return
        }
        guard request.retryCount < 1 else {
            log("retry → 401 but retryCount=\(request.retryCount) already exhausted, giving up")
            completion(.doNotRetry)
            return
        }

        log("retry → 401 received for \(request.request?.url?.path ?? "unknown")")

        guard tokenManager.refreshToken != nil else {
            log("retry → no refresh token, parking request for post-login retry")
            lock.lock()
            postLoginQueue.append(completion)
            lock.unlock()
            tokenManager.clearTokensAndSignalExpiry()
            return
        }

        let currentAttempts = tokenManager.refreshAttemptCount
        guard currentAttempts < maxRefreshAttempts else {
            log("retry → max refresh attempts (\(maxRefreshAttempts)) reached, parking request for post-login retry")
            lock.lock()
            postLoginQueue.append(completion)
            lock.unlock()
            tokenManager.clearTokensAndSignalExpiry()
            return
        }

        lock.lock()
        if isRefreshing {
            log("retry → refresh already in-flight, queuing request (queue size: \(pendingRetryCompletions.count + 1))")
            pendingRetryCompletions.append(completion)
            lock.unlock()
            return
        }
        isRefreshing = true
        lock.unlock()

        log("retry → starting token refresh (attempt \(currentAttempts + 1)/\(maxRefreshAttempts))")
        performRefresh { [weak self] success in
            guard let self else { return }
            self.flushAfterRefresh(success: success, retryCompletion: completion)
        }
    }

    // MARK: - Flush after refresh
    private func flushAfterRefresh(
        success: Bool,
        originalRequest: URLRequest? = nil,
        adaptCompletion: ((Result<URLRequest, Error>) -> Void)? = nil,
        retryCompletion: ((RetryResult) -> Void)? = nil
    ) {
        lock.lock()
        isRefreshing = false
        let pendingAdapts = pendingAdaptCompletions
        pendingAdaptCompletions = []
        let pendingRetries = pendingRetryCompletions
        pendingRetryCompletions = []
        lock.unlock()

        if success {
            log("refresh succeeded — flushing \(pendingAdapts.count) adapt(s) + \(pendingRetries.count) retry(s)")
            let freshToken = tokenManager.accessToken

            if let urlRequest = originalRequest, let adapt = adaptCompletion {
                var req = urlRequest
                if let ft = freshToken { req.setValue("Bearer \(ft)", forHTTPHeaderField: "Authorization") }
                adapt(.success(req))
            }
            for (queuedRequest, queuedCompletion) in pendingAdapts {
                var req = queuedRequest
                if let ft = freshToken { req.setValue("Bearer \(ft)", forHTTPHeaderField: "Authorization") }
                queuedCompletion(.success(req))
            }

            retryCompletion?(.retry)
            pendingRetries.forEach { $0(.retry) }
        } else {
            log("refresh failed — parking \(pendingRetries.count + (retryCompletion != nil ? 1 : 0)) retry(s) for post-login retry")
            lock.lock()
            if let rc = retryCompletion { postLoginQueue.append(rc) }
            postLoginQueue.append(contentsOf: pendingRetries)
            lock.unlock()

            if let urlRequest = originalRequest, let adapt = adaptCompletion {
                var req = urlRequest
                if let t = tokenManager.accessToken { req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
                adapt(.success(req))
            }
            for (queuedRequest, queuedCompletion) in pendingAdapts {
                var req = queuedRequest
                if let t = tokenManager.accessToken { req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization") }
                queuedCompletion(.success(req))
            }
        }
    }

    // MARK: - Token Refresh
    private func performRefresh(completion: @escaping (Bool) -> Void) {
        let refreshToken = tokenManager.refreshToken!
        let attemptNumber = tokenManager.refreshAttemptCount + 1

        log("performRefresh → attempt \(attemptNumber)/\(maxRefreshAttempts), POST \(NetworkConfig.Endpoint.refresh)")
        refreshSession.request(
            NetworkConfig.baseURL + NetworkConfig.Endpoint.refresh,
            method: .post,
            parameters: RefreshTokenRequest(refreshToken: refreshToken),
            encoder: JSONParameterEncoder.default
        )
        .validate()
        .responseDecodable(of: APIResponse<TokenData>.self) { [weak self] response in
            switch response.result {
            case .success(let apiResponse) where apiResponse.success == true:
                if let newToken = apiResponse.data?.accessToken {
                    let newRefresh = apiResponse.data?.refreshToken ?? refreshToken
                    self?.tokenManager.saveTokens(access: newToken, refresh: newRefresh)
                    self?.tokenManager.incrementRefreshAttemptCount()
                    let count = self?.tokenManager.refreshAttemptCount ?? 0
                    self?.log("performRefresh → success (\(count)/\(self?.maxRefreshAttempts ?? 3)), new access token …\(String(newToken.suffix(8)))")
                    completion(true)
                } else {
                    self?.log("performRefresh → server returned success=true but no accessToken")
                    self?.tokenManager.clearTokensAndSignalExpiry()
                    completion(false)
                }
            case .success(let apiResponse):
                self?.log("performRefresh → server returned success=false: \(apiResponse.message ?? "no message")")
                self?.tokenManager.clearTokensAndSignalExpiry()
                completion(false)
            case .failure(let error):
                self?.log("performRefresh → network/HTTP error: \(error.localizedDescription)")
                self?.tokenManager.clearTokensAndSignalExpiry()
                completion(false)
            }
        }
    }

    // MARK: - JWT Utilities
    private func isTokenExpiredOrExpiringSoon(_ token: String) -> Bool {
        guard let payload = decodeJWTPayload(token),
              let exp = payload["exp"] as? TimeInterval else { return false }
        return Date(timeIntervalSince1970: exp) < Date().addingTimeInterval(60)
    }

    private func decodeJWTPayload(_ token: String) -> [String: Any]? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }
        var base64 = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return json
    }

    // MARK: - Logging
    private func log(_ message: String) {
        print("[AuthInterceptor] \(message)")
    }
}
