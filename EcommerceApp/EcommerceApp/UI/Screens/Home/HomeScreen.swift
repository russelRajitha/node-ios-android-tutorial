import SwiftUI

struct HomeScreen: View {
    @State private var viewModel = AppContainer.shared.container.resolve(ShopViewModel.self)!
    @Environment(\.appColors) private var colors

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                categoriesSection
            }
            .padding(16)
            .padding(.bottom, 8)
        }
        .navigationTitle("Shop")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: AppRoute.configurations) {
                    Image(systemName: "gearshape")
                }
            }
        }
        .navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .configurations:
                ConfigurationsScreen()
            case .categoryDetail(let id, let name):
                CategoryProductsScreen(categoryId: id, categoryName: name)
            case .productDetail(let id):
                ProductDetailScreen(productId: id)
            default:
                EmptyView()
            }
        }
        .task { await viewModel.loadCategories() }
    }

    // MARK: - Categories Section
    @ViewBuilder
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Categories")

            switch viewModel.state {
            case .idle, .loading:
                categoriesLoadingGrid

            case .success(let categories):
                categoriesGrid(categories)

            case .error(let message):
                categoriesError(message)
            }
        }
    }

    private func categoriesGrid(_ categories: [ProductCategory]) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ForEach(categories) { category in
                NavigationLink(value: AppRoute.categoryDetail(id: category.id, name: category.name)) {
                    AppCategoryCard(title: category.name, imageURL: category.icon)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var categoriesLoadingGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 16)
                    .fill(colors.backgroundElevated)
                    .aspectRatio(1, contentMode: .fit)
                    .shimmering()
            }
        }
    }

    private func categoriesError(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(colors.textSecondary)
                .multilineTextAlignment(.center)
            AppButton(title: "Retry", icon: .system("arrow.clockwise")) {
                Task { await viewModel.loadCategories() }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - Preview

#Preview("HomeScreen") {
    NavigationStack {
        HomeScreen()
    }
    .environmentObject(ThemeManager())
    .applyAppColors()
}

#Preview("HomeScreen – Dark") {
    NavigationStack {
        HomeScreen()
    }
    .environmentObject(ThemeManager())
    .applyAppColors()
    .preferredColorScheme(.dark)
}
