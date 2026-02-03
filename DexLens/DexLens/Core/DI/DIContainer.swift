import Foundation

/// Dependency Injection Container for managing app services.
///
/// This singleton container provides protocol-based service registration
/// and resolution, enabling loose coupling and easy testing.
///
/// ## Usage
/// ```swift
/// // Register a service (typically in AppDelegate or App init)
/// DIContainer.shared.register(HomeServiceProtocol.self, instance: HomeService())
///
/// // Resolve a service anywhere in the app
/// let homeService = DIContainer.shared.resolve(HomeServiceProtocol.self)
/// ```
///
/// ## Benefits
/// - **Centralized**: All services created and managed in one place
/// - **Testable**: Easy to swap with mock implementations for unit tests
/// - **Decoupled**: Components depend on protocols, not concrete implementations
/// - **Protocol-based**: Services are registered and resolved by protocol type
final class DIContainer {
    static let shared = DIContainer()

    private var services: [String: Any] = [:]

    private init() {}

    /// Registers a service instance with a specific protocol type.
    ///
    /// Use this method to register your services at app startup.
    ///
    /// - Parameters:
    ///   - type: The protocol type to register under.
    ///   - instance: The service instance to register.
    ///
    /// Example:
    /// ```swift
    /// DIContainer.shared.register(APIClientProtocol.self, instance: APIClient())
    /// ```
    func register<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        services[key] = instance
    }

    /// Resolves a service instance by protocol type.
    ///
    /// - Parameter type: The protocol type to resolve.
    /// - Returns: The registered service instance, or `nil` if not found.
    ///
    /// Example:
    /// ```swift
    /// let apiClient = DIContainer.shared.resolve(APIClientProtocol.self)
    /// ```
    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return services[key] as? T
    }
}
