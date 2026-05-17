//
//  ContentView.swift
//  EcommerceApp
//
//  Created by Russel Rajitha  on 2026-05-17.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var themeManager = AppContainer.shared.container.resolve(ThemeManager.self)!
    @State private var selectedTab: AppTab = .shop
    @State private var showSessionExpiredLogin = false
    @State private var notificationsPath: [AppRoute] = []

    private let tokenManager = AppContainer.shared.container.resolve(TokenManager.self)!

    var body: some View {
        tabContent
            .safeAreaInset(edge: .bottom, spacing: 0) {
                AppTabBar(selectedTab: $selectedTab)
            }
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.colorScheme)
            .applyAppColors()
            .sheet(isPresented: $showSessionExpiredLogin) {
                LoginSheet(isPresented: $showSessionExpiredLogin, canDismiss: false)
                    .environmentObject(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
                    .applyAppColors()
            }
            .onReceive(tokenManager.sessionExpiredPublisher) { _ in
                showSessionExpiredLogin = true
            }
            .onAppear {
                if let url = DeepLinkManager.shared.drainPendingURL() {
                    handleDeepLink(url)
                }
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .onReceive(DeepLinkManager.shared.publisher) { url in
                _ = DeepLinkManager.shared.drainPendingURL()
                handleDeepLink(url)
            }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .shop:
            NavigationStack { HomeScreen() }
        case .cart:
            NavigationStack { CartScreen() }
        case .notifications:
            NavigationStack(path: $notificationsPath) { NotificationsScreen() }
        case .profile:
            NavigationStack {
                ProfileScreen()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .orders:
                            OrdersScreen()
                        case .orderDetail(let id):
                            OrderDetailScreen(orderId: id)
                        default:
                            EmptyView()
                        }
                    }
            }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "app" else { return }
        switch url.host {
        case "home", "shop":
            selectedTab = .shop
        case "cart":
            selectedTab = .cart
        case "notifications":
            selectedTab = .notifications
            let orderId = url.pathComponents.dropFirst().first
            notificationsPath = orderId.map { [.orderDetail(id: $0)] } ?? []
        case "profile":
            selectedTab = .profile
        default:
            break
        }
    }
}

#Preview {
    ContentView()
}
