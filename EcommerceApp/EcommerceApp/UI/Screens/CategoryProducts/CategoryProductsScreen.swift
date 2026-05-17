import SwiftUI

struct CategoryProductsScreen: View {
    let categoryId: String
    let categoryName: String

    @State private var viewModel = AppContainer.shared.container.resolve(CategoryProductsViewModel.self)!
    @Environment(\.appColors) private var colors

    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .idle, .loading:
                productsLoadingGrid
                    .padding(16)

            case .success(let detail):
                if detail.products.isEmpty {
                    emptyView
                        .padding(16)
                } else {
                    productsGrid(detail.products)
                        .padding(16)
                }

            case .error(let message):
                errorView(message)
                    .padding(16)
            }
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load(categoryId: categoryId) }
    }

    // MARK: - Products Grid
    private func productsGrid(_ products: [CategoryProduct]) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ForEach(products) { product in
                NavigationLink(value: AppRoute.productDetail(id: product.id)) {
                    AppProductCard(name: product.name, price: product.price, imageURL: product.image)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Loading
    private var productsLoadingGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ForEach(0..<6, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(colors.backgroundElevated)
                    .aspectRatio(0.8, contentMode: .fit)
                    .shimmering()
            }
        }
    }

    // MARK: - Empty
    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(colors.textDisabled)
            Text("No products in this category")
                .font(.subheadline)
                .foregroundStyle(colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Error
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(colors.textSecondary)
                .multilineTextAlignment(.center)
            AppButton(title: "Retry", icon: .system("arrow.clockwise")) {
                Task { await viewModel.load(categoryId: categoryId) }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - Preview
#Preview("CategoryProductsScreen") {
    NavigationStack {
        CategoryProductsScreen(
            categoryId: "6999b49f-6636-44f8-9102-196eccddb2e5",
            categoryName: "Electronics"
        )
    }
    .applyAppColors()
}
