import Swinject
import SwiftData

/// All singleton services use .container scope; ViewModels are transient (new per screen).
final class AppContainer {
    static let shared = AppContainer()
    let container: Container

    let modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: CartItemModel.self)
        } catch {
            fatalError("SwiftData container failed to initialize: \(error)")
        }
    }()

    private init() {
        container = Container()
        registerDependencies()
    }

    private func registerDependencies() {

        // MARK: - Config
        container.register(ThemeManager.self) { _ in
            ThemeManager()
        }.inObjectScope(.container)

        // MARK: - Storage
        container.register(TokenManager.self) { _ in
            TokenManager()
        }.inObjectScope(.container)

        // MARK: - Network
        // NetworkService owns both Sessions (noAuth + auth) and wires AuthInterceptor internally
        container.register(NetworkService.self) { r in
            NetworkService(tokenManager: r.resolve(TokenManager.self)!)
        }.inObjectScope(.container)

        container.register(AuthAPIService.self) { r in
            AuthAPIService(networkService: r.resolve(NetworkService.self)!)
        }.inObjectScope(.container)

        container.register(UserAPIService.self) { r in
            UserAPIService(networkService: r.resolve(NetworkService.self)!)
        }.inObjectScope(.container)

        container.register(ProductCategoryAPIService.self) { r in
            ProductCategoryAPIService(networkService: r.resolve(NetworkService.self)!)
        }.inObjectScope(.container)

        container.register(ProductAPIService.self) { r in
            ProductAPIService(networkService: r.resolve(NetworkService.self)!)
        }.inObjectScope(.container)

        container.register(CartAPIService.self) { r in
            CartAPIService(networkService: r.resolve(NetworkService.self)!)
        }.inObjectScope(.container)

        container.register(OrderAPIService.self) { r in
            OrderAPIService(networkService: r.resolve(NetworkService.self)!)
        }.inObjectScope(.container)

        container.register(NotificationAPIService.self) { r in
            NotificationAPIService(networkService: r.resolve(NetworkService.self)!)
        }.inObjectScope(.container)

        container.register(DeviceTokenAPIService.self) { r in
            DeviceTokenAPIService(networkService: r.resolve(NetworkService.self)!)
        }.inObjectScope(.container)

        // MARK: - Repositories
        container.register(DeviceTokenRepository.self) { r in
            DeviceTokenRepository(apiService: r.resolve(DeviceTokenAPIService.self)!)
        }.inObjectScope(.container)

        container.register(AuthRepository.self) { r in
            AuthRepository(
                authAPIService: r.resolve(AuthAPIService.self)!,
                tokenManager: r.resolve(TokenManager.self)!,
                deviceTokenRepository: r.resolve(DeviceTokenRepository.self)!,
                cartRepository: r.resolve(CartRepository.self)!
            )
        }.inObjectScope(.container)

        container.register(ProfileRepository.self) { r in
            ProfileRepository(userAPIService: r.resolve(UserAPIService.self)!)
        }.inObjectScope(.container)

        // mainContext is @MainActor; AppContainer.shared is always first accessed on the main thread.
        let cartContext = MainActor.assumeIsolated { modelContainer.mainContext }
        container.register(CartRepository.self) { r in
            CartRepository(
                context: cartContext,
                cartAPIService: r.resolve(CartAPIService.self)!
            )
        }.inObjectScope(.container)

        container.register(OrderRepository.self) { r in
            OrderRepository(apiService: r.resolve(OrderAPIService.self)!)
        }.inObjectScope(.container)

        container.register(NotificationRepository.self) { r in
            NotificationRepository(apiService: r.resolve(NotificationAPIService.self)!)
        }.inObjectScope(.container)

        container.register(ProductCategoryRepository.self) { r in
            ProductCategoryRepository(apiService: r.resolve(ProductCategoryAPIService.self)!)
        }.inObjectScope(.container)

        container.register(ProductRepository.self) { r in
            ProductRepository(apiService: r.resolve(ProductAPIService.self)!)
        }.inObjectScope(.container)

        // MARK: - ViewModels (transient — new instance per screen)
        container.register(ShopViewModel.self) { r in
            ShopViewModel(categoryRepository: r.resolve(ProductCategoryRepository.self)!)
        }

        container.register(CategoryProductsViewModel.self) { r in
            CategoryProductsViewModel(repository: r.resolve(ProductCategoryRepository.self)!)
        }

        container.register(LoginViewModel.self) { r in
            LoginViewModel(authRepository: r.resolve(AuthRepository.self)!)
        }

        container.register(ProfileViewModel.self) { r in
            ProfileViewModel(
                profileRepository: r.resolve(ProfileRepository.self)!,
                authRepository: r.resolve(AuthRepository.self)!
            )
        }

        container.register(CartViewModel.self) { r in
            CartViewModel(
                cartRepository: r.resolve(CartRepository.self)!,
                orderRepository: r.resolve(OrderRepository.self)!
            )
        }

        container.register(ProductDetailViewModel.self) { r in
            ProductDetailViewModel(
                repository: r.resolve(ProductRepository.self)!,
                cartRepository: r.resolve(CartRepository.self)!
            )
        }

        container.register(OrdersViewModel.self) { r in
            OrdersViewModel(orderRepository: r.resolve(OrderRepository.self)!)
        }

        container.register(OrderDetailViewModel.self) { r in
            OrderDetailViewModel(orderRepository: r.resolve(OrderRepository.self)!)
        }

        container.register(NotificationsViewModel.self) { r in
            NotificationsViewModel(notificationRepository: r.resolve(NotificationRepository.self)!)
        }
    }
}
