import SwiftUI

struct OrdersScreen: View {
    @State private var viewModel = AppContainer.shared.container.resolve(OrdersViewModel.self)!

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                AppSpinner()
            case .success(let orders):
                if orders.isEmpty {
                    ContentUnavailableView(
                        "No Orders",
                        systemImage: "bag",
                        description: Text("Your completed orders will appear here.")
                    )
                } else {
                    ordersList(orders)
                }
            case .error(let message):
                VStack(spacing: 16) {
                    Text(message)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    AppButton(title: "Retry", icon: .system("arrow.clockwise")) {
                        Task { await viewModel.loadOrders() }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .navigationTitle("Orders")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadOrders() }
        .navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .orderDetail(let id):
                OrderDetailScreen(orderId: id)
            default:
                EmptyView()
            }
        }
    }

    private func ordersList(_ orders: [OrderAPIResponse]) -> some View {
        List(orders) { order in
            NavigationLink(value: AppRoute.orderDetail(id: order.id)) {
                OrderRow(order: order)
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Order Row
private struct OrderRow: View {
    let order: OrderAPIResponse

    private var statusColor: Color {
        order.status == "delivered" ? .green : .orange
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(order.orderNumber)
                    .font(.headline)
                Spacer()
                Text(order.status.capitalized)
                    .font(.caption.bold())
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.12), in: Capsule())
            }
            HStack {
                Text(formattedDate(order.createdAt))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("$\(formattedTotal(order.total))")
                    .font(.subheadline.bold())
            }
        }
        .padding(.vertical, 4)
    }

    private func formattedDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: iso) else { return iso }
        let display = DateFormatter()
        display.dateStyle = .medium
        display.timeStyle = .none
        return display.string(from: date)
    }

    private func formattedTotal(_ total: String) -> String {
        guard let value = Double(total) else { return total }
        return String(format: "%.2f", value)
    }
}

// MARK: - Preview

#Preview("OrdersScreen") {
    NavigationStack {
        OrdersScreen()
    }
    .applyAppColors()
}

#Preview("OrdersScreen – Dark") {
    NavigationStack {
        OrdersScreen()
    }
    .applyAppColors()
    .preferredColorScheme(.dark)
}
