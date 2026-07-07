import SwiftUI

struct OrderDetailScreen: View {
    let orderId: String
    @State private var viewModel = AppContainer.shared.container.resolve(OrderDetailViewModel.self)!

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                AppSpinner()
            case .success(let order):
                orderContent(order)
            case .error(let message):
                VStack(spacing: 16) {
                    Text(message)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    AppButton(title: "Retry", icon: .system("arrow.clockwise")) {
                        Task { await viewModel.loadOrder(id: orderId) }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .navigationTitle("Order Detail")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadOrder(id: orderId) }
    }

    // MARK: - Order Content
    private func orderContent(_ order: OrderAPIResponse) -> some View {
        List {
            Section("Summary") {
                OrderDetailRow(label: "Order #", value: order.orderNumber)
                OrderDetailRow(label: "Date", value: formattedDate(order.createdAt))
                OrderDetailRow(label: "Status", value: order.status.capitalized, valueColor: statusColor(order.status))
                OrderDetailRow(label: "Total", value: "$\(formattedTotal(order.total))")
            }

            Section("Items") {
                ForEach(order.items ?? []) { item in
                    OrderItemRow(item: item)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func statusColor(_ status: String) -> Color {
        status == "delivered" ? .green : .orange
    }

    private func formattedDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: iso) else { return iso }
        let display = DateFormatter()
        display.dateStyle = .medium
        display.timeStyle = .short
        return display.string(from: date)
    }

    private func formattedTotal(_ total: String) -> String {
        guard let value = Double(total) else { return total }
        return String(format: "%.2f", value)
    }
}

// MARK: - Sub-Views
private struct OrderDetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
        }
    }
}

private struct OrderItemRow: View {
    let item: OrderAPIItem
    @Environment(\.appColors) private var colors

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colors.backgroundElevated)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.productName)
                    .font(.subheadline)
                    .lineLimit(2)
                HStack {
                    Text("$\(formattedPrice(item.productPrice))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Qty: \(item.quantity)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var imageURL: URL? {
        guard let img = item.productImage else { return nil }
        return URL(string: img.hasPrefix("http") ? img : "\(NetworkConfig.baseURL)\(img)")
    }

    private func formattedPrice(_ price: String) -> String {
        guard let value = Double(price) else { return price }
        return String(format: "%.2f", value)
    }
}

// MARK: - Preview

#Preview("OrderDetailScreen") {
    NavigationStack {
        OrderDetailScreen(orderId: "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
    }
    .applyAppColors()
}

#Preview("OrderDetailScreen – Dark") {
    NavigationStack {
        OrderDetailScreen(orderId: "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
    }
    .applyAppColors()
    .preferredColorScheme(.dark)
}
