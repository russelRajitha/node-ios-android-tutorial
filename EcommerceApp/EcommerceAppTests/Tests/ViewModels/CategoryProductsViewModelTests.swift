import Foundation
import Testing
@testable import EcommerceApp

@MainActor
struct CategoryProductsViewModelTests {

    @Test func load_success_returnsCategoryDetail() async {
        let repo = MockProductCategoryRepository()
        repo.stubbedCategoryDetail = makeCategoryDetail()
        let vm = CategoryProductsViewModel(repository: repo)
        await vm.load(categoryId: "c1")
        if case .success(let detail) = vm.state {
            #expect(detail.category.id == "c1")
        } else {
            Issue.record("Expected success state")
        }
    }

    @Test func load_apiError_setsError() async {
        let repo = MockProductCategoryRepository()
        repo.getCategoryDetailError = .apiError("Not found")
        let vm = CategoryProductsViewModel(repository: repo)
        await vm.load(categoryId: "c1")
        if case .error = vm.state { } else { Issue.record("Expected error state") }
    }

    @Test func load_networkError_setsError() async {
        let repo = MockProductCategoryRepository()
        repo.getCategoryDetailError = noConnection
        let vm = CategoryProductsViewModel(repository: repo)
        await vm.load(categoryId: "c1")
        if case .error = vm.state { } else { Issue.record("Expected error state on no connection") }
    }
}
