import Foundation

/// A lightweight Dependency Injection (DI) container for managing app-wide services.
///
/// `DIContainer` is a singleton responsible for registering and resolving shared
/// dependencies such as API clients and domain services. It enables loose coupling,
/// improves testability, and keeps object creation centralized and explicit.
///
/// The container is **type-safe**, using `ObjectIdentifier` instead of string keys,
/// and fails fast if a dependency is requested but not registered.
///
/// ## Architecture
/// - The container owns **infrastructure and services**
/// - Views and ViewModels receive dependencies via **constructor injection**
/// - ViewModels are typically created by views, not stored in the container
/// - App-specific wiring happens once via `configure()` at app launch
///
/// ## Usage
///
/// ### App setup (composition root)
/// Call `configure()` once at app startup to wire all dependencies:
///
/// ### Registering services
/// Services are registered by protocol type:
///
/// ```swift
/// let apiClient = APIClient()
/// DIContainer.shared.register(APIClientProtocol.self, instance: apiClient)
/// ```
///
/// ### Resolving services
/// Dependencies can be resolved anywhere after configuration:
///
/// ```swift
/// let homeService = DIContainer.shared.resolve(HomeServiceProtocol.self)
/// ```
///
/// If a dependency has not been registered, the app will terminate with a clear
/// error message, making misconfiguration obvious during development.
///
/// ## Benefits
/// - **Type-safe**: Uses type identifiers instead of string keys
/// - **Centralized**: All service wiring lives in one place
/// - **Decoupled**: Components depend on protocols, not implementations
/// - **Testable**: Easy to inject mocks or alternate implementations
/// - **Explicit**: No magic, reflection, or framework lock-in
final class DIContainer {
    static let shared = DIContainer()

    private var services: [ObjectIdentifier: Any] = [:]

    private init() {}

    /// Registers a concrete instance for a given protocol or type.
    ///
    /// - Parameters:
    ///   - type: The protocol or type to register.
    ///   - instance: The concrete instance to associate with the type.
    func register<T>(_ type: T.Type, instance: T) {
        let key = ObjectIdentifier(type)
        services[key] = instance
    }

    /// Configures and registers all app-wide dependencies.
    ///
    /// This method acts as the app's **composition root** and should be called
    /// once during app startup.
    func configure() {
        let apiClient = APIClient()

        register(APIClientProtocol.self, instance: apiClient)

        let homeService = HomeService(apiClient: apiClient)
        register(HomeServiceProtocol.self, instance: homeService)

        let perpetualService = HyperliquidPerpetualService(apiClient: apiClient)
        register(PerpetualServiceProtocol.self, instance: perpetualService)

        // MARK: - Wallet Discovery Infrastructure

        let persistenceController = PersistenceController.shared
        register(PersistenceController.self, instance: persistenceController)

        let walletRepository = WalletRepositoryImpl(persistenceController: persistenceController)
        register(WalletRepository.self, instance: walletRepository)

        let walletDiscoveryService = WalletDiscoveryService(
            apiClient: apiClient,
            repository: walletRepository
        )
        register(WalletDiscoveryServiceProtocol.self, instance: walletDiscoveryService)
    }

    /// Resolves a previously registered dependency.
    ///
    /// - Parameter type: The protocol or type to resolve.
    /// - Returns: The registered instance.
    /// - Note: The app will terminate if the dependency is not registered.
    func resolve<T>(_ type: T.Type) -> T {
        let key = ObjectIdentifier(type)

        guard let service = services[key] as? T else {
            fatalError("❌ No dependency registered for \(type)")
        }

        return service
    }
}
