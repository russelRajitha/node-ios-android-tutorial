import Combine
import Foundation

final class DeepLinkManager {
    static let shared = DeepLinkManager()
    private init() {}

    private let subject = PassthroughSubject<URL, Never>()

    private(set) var pendingURL: URL?

    var publisher: AnyPublisher<URL, Never> { subject.eraseToAnyPublisher() }

    func send(_ url: URL) {
        pendingURL = url
        subject.send(url)
    }

    func drainPendingURL() -> URL? {
        defer { pendingURL = nil }
        return pendingURL
    }
}
