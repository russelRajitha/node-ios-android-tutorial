import SwiftUI

struct ProductDetailScreen: View {
    let productId: String

    @State private var viewModel = AppContainer.shared.container.resolve(ProductDetailViewModel.self)!
    @Environment(\.appColors) private var colors

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                loadingView
            case .success(let product):
                productContent(product)
            case .error(let message):
                errorView(message)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load(productId: productId) }
    }

    // MARK: - Product Content
    @ViewBuilder
    private func productContent(_ product: ProductDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AppImageSlider(imageURLs: sliderImages(for: product))
                    .frame(height: 320)
                detailsSection(product)
            }
        }
        .navigationTitle("")
    }

    private func sliderImages(for product: ProductDetail) -> [String] {
        print("product",product)
        let gallery = product.images.map { $0.image }
        print("gallery",gallery)
        if !gallery.isEmpty { return gallery }
        if let fallback = product.image { return [fallback] }
        return []
    }

    @ViewBuilder
    private func detailsSection(_ product: ProductDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                if let category = product.category {
                    Label(category.name, systemImage: "tag")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(colors.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(colors.primary.opacity(0.1))
                        .clipShape(Capsule())
                }
                Spacer()
                Text(product.stock > 0 ? "In Stock: \(product.stock)" : "Out of Stock")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(product.stock > 0 ? colors.success : colors.error)
            }

            Text(product.name)
                .font(.title2.bold())
                .foregroundStyle(colors.textPrimary)

            Text(product.brand)
                .font(.subheadline)
                .foregroundStyle(colors.textSecondary)

            Text("$\(product.price)")
                .font(.title.bold())
                .foregroundStyle(colors.primary)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)
                    .foregroundStyle(colors.textPrimary)
                Text(product.description)
                    .font(.body)
                    .foregroundStyle(colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            AppButton(
                title: viewModel.cartState == .success ? "Added to Cart" : "Add to Cart",
                icon: .system(viewModel.cartState == .success ? "checkmark.circle.fill" : "cart.badge.plus"),
                isLoading: viewModel.cartState == .loading
            ) {
                Task { await viewModel.addToCart(product: product) }
            }
            .disabled(viewModel.cartState != .idle)
        }
        .padding(16)
    }

    // MARK: - Loading
    private var loadingView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(colors.backgroundElevated)
                .frame(maxWidth: .infinity)
                .frame(height: 320)
                .shimmering()

            VStack(alignment: .leading, spacing: 16) {
                ForEach([0.6, 0.9, 0.4, 1.0, 0.75], id: \.self) { fraction in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(colors.backgroundElevated)
                        .frame(maxWidth: .infinity)
                        .scaleEffect(x: fraction, anchor: .leading)
                        .frame(height: 18)
                        .shimmering()
                }
            }
            .padding(16)

            Spacer()
        }
    }

    // MARK: - Error
    @ViewBuilder
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(colors.textSecondary)
                .multilineTextAlignment(.center)
            AppButton(title: "Retry", icon: .system("arrow.clockwise")) {
                Task { await viewModel.load(productId: productId) }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - Previews
#Preview("ProductDetailScreen") {
    NavigationStack {
        ProductDetailScreen(productId: "f060d91e-f97d-4513-a261-168847607c6b")
    }
    .applyAppColors()
}

#Preview("ProductDetailScreen – Dark") {
    NavigationStack {
        ProductDetailScreen(productId: "f060d91e-f97d-4513-a261-168847607c6b")
    }
    .applyAppColors()
    .preferredColorScheme(.dark)
}
