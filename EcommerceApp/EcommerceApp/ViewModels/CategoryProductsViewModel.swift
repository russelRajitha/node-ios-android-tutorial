import Foundation

@Observable @MainActor final class CategoryProductsViewModel {
    enum State {
        case idle
        case loading
        case success(CategoryDetail)
        case error(String)
    }

    private(set) var state: State = .idle
    private let repository: any ProductCategoryRepositoryProtocol

    nonisolated init(repository: any ProductCategoryRepositoryProtocol) {
        self.repository = repository
    }

    func load(categoryId: String) async {
        state = .loading
        do {
            state = .success(try await repository.getCategoryDetail(id: categoryId))
        } catch let e as APIError {
            state = .error(e.localizedDescription)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
