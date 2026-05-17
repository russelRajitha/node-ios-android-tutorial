import Alamofire
import Foundation

final class NetworkService {

    let noAuthSession: Session
    let authSession: Session

    init(tokenManager: TokenManager) {
        let config = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest = NetworkConfig.Timeout.standard

        let logger = NetworkLogger()

        let refreshSession = Session(configuration: config, eventMonitors: [logger])
        noAuthSession = Session(configuration: config, eventMonitors: [logger])

        let interceptor = AuthInterceptor(tokenManager: tokenManager, refreshSession: refreshSession)
        authSession = Session(configuration: config, interceptor: interceptor, eventMonitors: [logger])
    }

    // MARK: - Unauthenticated (login, refresh)
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get
    ) async throws -> T {
        try await perform(session: noAuthSession, endpoint: endpoint, method: method, mapUnauthorized: true)
    }

    func request<T: Decodable, Body: Encodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Body
    ) async throws -> T {
        try await perform(session: noAuthSession, endpoint: endpoint, method: method, body: body, mapUnauthorized: true)
    }

    // MARK: - Authenticated (protected endpoints)
    func authenticatedRequest<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get
    ) async throws -> T {
        try await perform(session: authSession, endpoint: endpoint, method: method)
    }

    func authenticatedRequest<T: Decodable, Body: Encodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Body
    ) async throws -> T {
        try await perform(session: authSession, endpoint: endpoint, method: method, body: body)
    }

    // MARK: - Internal
    private func perform<T: Decodable>(
        session: Session,
        endpoint: String,
        method: HTTPMethod,
        mapUnauthorized: Bool = false
    ) async throws -> T {
        let response = await session
            .request(NetworkConfig.baseURL + endpoint, method: method)
            .validate()
            .serializingDecodable(T.self)
            .response
        return try decodeOrThrow(response, mapUnauthorized: mapUnauthorized)
    }

    private func perform<T: Decodable, Body: Encodable>(
        session: Session,
        endpoint: String,
        method: HTTPMethod,
        body: Body,
        mapUnauthorized: Bool = false
    ) async throws -> T {
        let response = await session
            .request(
                NetworkConfig.baseURL + endpoint,
                method: method,
                parameters: body,
                encoder: JSONParameterEncoder.default
            )
            .validate()
            .serializingDecodable(T.self)
            .response
        return try decodeOrThrow(response, mapUnauthorized: mapUnauthorized)
    }

    private func decodeOrThrow<T: Decodable>(
        _ response: DataResponse<T, AFError>,
        mapUnauthorized: Bool
    ) throws -> T {
        let statusCode = response.response?.statusCode ?? 0
        if statusCode == 401 && !mapUnauthorized {
            throw APIError.unauthorized
        }
        if !(200...299).contains(statusCode) {
            if let data = response.data,
               let body = try? JSONDecoder().decode(ServerErrorBody.self, from: data) {
                throw APIError.validationError(
                    message: body.message ?? "Server error: \(statusCode)",
                    fieldErrors: body.errors
                )
            }
            throw APIError.serverError(statusCode)
        }
        guard let value = response.value else {
            throw response.error.map(mapAFError(_:)) ?? APIError.noData
        }
        return value
    }

    private func mapAFError(_ afError: AFError) -> APIError {
        if case .responseSerializationFailed(let reason) = afError,
           case .decodingFailed(let error) = reason {
            return .decodingError(error)
        }
        return .networkError(afError)
    }
}

private struct ServerErrorBody: Decodable {
    let message: String?
    let errors: [String: [String]]?
}

// MARK: - Network Logger
private final class NetworkLogger: EventMonitor {

    func requestDidFinish(_ request: Request) {
        let method = request.request?.httpMethod ?? "?"
        let url    = request.request?.url?.absoluteString ?? "?"
        print("[NetworkLogger] → \(method) \(url)")
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        let url    = request.request?.url?.path ?? "?"
        let status = response.response?.statusCode ?? 0
        let symbol = (200...299).contains(status) ? "✓" : "✗"
        print("[NetworkLogger] ← \(symbol) HTTP \(status) \(url)")
    }
}
