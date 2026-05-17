import SwiftUI

struct NotificationsScreen: View {
    @State private var viewModel = AppContainer.shared.container.resolve(NotificationsViewModel.self)!
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                AppSpinner()
            case .success(let notifications):
                if notifications.isEmpty {
                    ContentUnavailableView(
                        "No Notifications",
                        systemImage: "bell.slash",
                        description: Text("You're all caught up.")
                    )
                } else {
                    notificationsList(notifications)
                }
            case .error(let message):
                VStack(spacing: 16) {
                    Text(message)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    AppButton(title: "Retry", icon: .system("arrow.clockwise")) {
                        Task { await viewModel.loadNotifications() }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadNotifications() }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await viewModel.loadNotifications() }
            }
        }
        .navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .orderDetail(let id):
                OrderDetailScreen(orderId: id)
            default:
                EmptyView()
            }
        }
    }

    private func notificationsList(_ notifications: [AppNotification]) -> some View {
        List(notifications) { notification in
            NotificationRow(notification: notification)
                .contentShape(Rectangle())
                .onTapGesture {
                    Task { await viewModel.markRead(notification) }
                }
        }
        .listStyle(.plain)
    }
}

// MARK: - Notification Row
private struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(notification.isRead ? Color.clear : Color.accentColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundStyle(notification.isRead ? .secondary : .primary)
                    Spacer()
                    if let orderId = notification.orderId {
                        NavigationLink(value: AppRoute.orderDetail(id: orderId)) {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Text(notification.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(formattedDate(notification.createdAt))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    private func formattedDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: iso) else { return iso }
        let display = RelativeDateTimeFormatter()
        display.unitsStyle = .abbreviated
        return display.localizedString(for: date, relativeTo: Date())
    }
}
