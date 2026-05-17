import Foundation
import Testing
@testable import EcommerceApp

@MainActor
struct ShopViewModelTests {

    @Test func loadCategories_success_returnsCategories() async {
        let repo = MockProductCategoryRepository()
        repo.stubbedCategories = [makeCategory(), ProductCategory(id: "c2", name: "Clothing", icon: "shirt")]
        let vm = ShopViewModel(categoryRepository: repo)
        await vm.loadCategories()
        if case .success(let cats) = vm.state {
            #expect(cats.count == 2)
        } else {
            Issue.record("Expected success state")
        }
    }

    @Test func loadCategories_emptyList_setsSuccess() async {
        let repo = MockProductCategoryRepository()
        let vm = ShopViewModel(categoryRepository: repo)
        await vm.loadCategories()
        if case .success(let cats) = vm.state {
            #expect(cats.isEmpty)
        } else {
            Issue.record("Expected success state")
        }
    }

    @Test func loadCategories_apiError_setsError() async {
        let repo = MockProductCategoryRepository()
        repo.getCategoriesError = .apiError("Server error")
        let vm = ShopViewModel(categoryRepository: repo)
        await vm.loadCategories()
        if case .error = vm.state { } else { Issue.record("Expected error state") }
    }

    @Test func loadCategories_networkError_setsError() async {
        let repo = MockProductCategoryRepository()
        repo.getCategoriesError = networkTimeout
        let vm = ShopViewModel(categoryRepository: repo)
        await vm.loadCategories()
        if case .error = vm.state { } else { Issue.record("Expected error state on network timeout") }
    }
}
