import Foundation

@Observable
@MainActor
final class ShopViewModel {
    enum State {
        case idle
        case loading
        case success([ProductCategory])
        case error(String)
    }

    private(set) var state: State = .idle

    private let categoryRepository: any ProductCategoryRepositoryProtocol

    nonisolated init(categoryRepository: any ProductCategoryRepositoryProtocol) {
        self.categoryRepository = categoryRepository
    }

    func loadCategories() async {
        state = .loading
        do {
            let categories = try await categoryRepository.getCategories()
            state = .success(categories)
        } catch let e as APIError {
            state = .error(e.localizedDescription)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
