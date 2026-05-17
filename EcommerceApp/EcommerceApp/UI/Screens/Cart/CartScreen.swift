import SwiftUI

struct CartScreen: View {
    @State private var viewModel = AppContainer.shared.container.resolve(CartViewModel.self)!
    @State private var searchText = ""

    private var filteredItems: [CartItem] {
        searchText.isEmpty
            ? viewModel.items
            : viewModel.items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List {
            ForEach(filteredItems) { item in
                CartRow(item: item,
                        onIncrease: { viewModel.increase(item) },
                        onDecrease: { viewModel.decrease(item) },
                        onRemove: { viewModel.remove(item) })
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.isLoading {
                AppSpinner()
            } else if filteredItems.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "Cart is Empty" : "No Results",
                    systemImage: searchText.isEmpty ? "cart" : "magnifyingglass",
                    description: Text(searchText.isEmpty ? "Add items from a product page" : "No items match \"\(searchText)\"")
                )
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) { bottomBar }
        .navigationTitle("Cart (\(viewModel.totalItems))")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search cart")
        .task { await viewModel.loadCart() }
        .alert("Checkout Failed", isPresented: Binding(
            get: { viewModel.checkoutError != nil },
            set: { if !$0 { viewModel.dismissCheckoutError() } }
        )) {
            Button("OK") { viewModel.dismissCheckoutError() }
        } message: {
            Text(viewModel.checkoutError ?? "")
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.totalPrice, format: .currency(code: "USD"))
                        .font(.title2.bold())
                }
                Spacer()
                Button {
                    Task { await viewModel.checkout() }
                } label: {
                    if viewModel.isCheckingOut {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Checkout")
                            .fontWeight(.semibold)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.items.isEmpty || viewModel.isCheckingOut)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(.regularMaterial)
    }
}

private struct CartRow: View {
    let item: CartItem
    let onIncrease: () -> Void
    let onDecrease: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text(item.price * Double(item.quantity), format: .currency(code: "USD"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            AppQuantityControl(quantity: item.quantity, onIncrease: onIncrease, onDecrease: onDecrease)
                .accessibilityLabel("Quantity for \(item.name)")
                .accessibilityValue("\(item.quantity)")
            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .padding(.leading, 8)
            .accessibilityLabel("Remove \(item.name)")
        }
        .padding(.vertical, 4)
    }
}
