import Foundation

enum APIResult<T> {
    case success(T)
    case apiError(message: String, errors: [String])
    case networkError(Error)
    case unauthorized
}

// MARK: - API Errors
enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case unauthorized
    case maxRetriesExceeded
    case apiError(String)
    case networkError(Error)
    case validationError(message: String, fieldErrors: [String: [String]]?)

    var errorDescription: String? {
        switch self {
        case .invalidURL:               return "Invalid URL"
        case .noData:                   return "No data received"
        case .decodingError(let e):     return "Decoding failed: \(e.localizedDescription)"
        case .serverError(let code):    return "Server error: \(code)"
        case .unauthorized:             return "Session expired. Please log in again."
        case .maxRetriesExceeded:       return "Max retries exceeded"
        case .apiError(let msg):        return msg
        case .networkError(let e):      return e.localizedDescription
        case .validationError(let msg, _): return msg
        }
    }
}
