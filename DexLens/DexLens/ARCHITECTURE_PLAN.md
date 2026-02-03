# DexLens - iOS MVVM Architecture Plan

## Project Overview
iOS Project, implementing MVVM architecture, protocol-oriented programming, async/await networking, and comprehensive unit testing.

## Directory Structure

```
DexLens/
├── App/
│   └── DexLensApp.swift
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift
│   │   ├── APIClientProtocol.swift
│   │   ├── NetworkError.swift
│   │   └── Endpoint.swift
│   ├── Protocols/
│   │   ├── ServiceProtocol.swift
│   │   └── ViewModelProtocol.swift
│   └── DI/
│       └── DIContainer.swift
├── Features/
│   ├── Home/
│   │   ├── Views/
│   │   │   └── HomeView.swift
│   │   ├── ViewModels/
│   │   │   ├── HomeViewModel.swift
│   │   │   └── HomeViewModelProtocol.swift
│   │   └── Services/
│   │       ├── HomeService.swift
│   │       └── HomeServiceProtocol.swift
│   └── Models/
│       ├── Response/
│       └── Domain/
├── Resources/
│   └── Assets.xcassets
└── ContentView.swift (Root navigation)
```

## Architecture Layers

| Layer | Pattern | Key Features |
|-------|---------|--------------|
| Network | Protocol-based | `APIClientProtocol`, async/await, generic `fetch` |
| Services | Protocol-first | `HomeServiceProtocol`, dependency injection ready |
| ViewModels | ObservableObject + Protocol | `HomeViewModelProtocol`, MainActor |
| Views | SwiftUI | State-driven, MVVM binding |

## Core/Network Layer Design

### NetworkError.swift
```swift
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
}
```

### Endpoint.swift
```swift
protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    
    var url: URL? { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
```

### APIClient.swift
```swift
protocol APIClientProtocol {
    func fetch<T: Decodable>(endpoint: Endpoint) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }
    
    func fetch<T: Decodable>(endpoint: Endpoint) async throws -> T {
        // Implementation
    }
}
```

## Core/Protocols Design

### ServiceProtocol.swift
```swift
protocol ServiceProtocol {
    var apiClient: APIClientProtocol { get }
}
```

### ViewModelProtocol.swift
```swift
@MainActor
protocol ViewModelProtocol: ObservableObject {
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
    func handleError(_ error: Error)
}
```

## Core/Dependency Injection

### DIContainer.swift
```swift
final class DIContainer {
    static let shared = DIContainer()
    
    private var services: [String: Any] = [:]
    
    func register<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        services[key] = instance
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return services[key] as? T
    }
}
```

## To-Do List

### Phase 1: Foundation (High Priority)

- [ ] Create Core/Network/NetworkError.swift
  - Enum with cases: invalidURL, invalidResponse, serverError(statusCode), decodingError, networkError
  - LocalizedError conformance for user-friendly messages

- [ ] Create Core/Network/Endpoint.swift
  - Protocol with baseURL, path, method, headers, parameters
  - HTTPMethod enum (GET, POST, PUT, PATCH, DELETE)
  - Computed property for URL construction

- [ ] Create Core/Network/APIClient.swift
  - APIClientProtocol with async fetch generic method
  - URLSession-based implementation with JSONDecoder
  - Error handling with NetworkError

- [ ] Create Core/Protocols/ServiceProtocol.swift
  - Base protocol for all services
  - APIClientProtocol dependency

- [ ] Create Core/Protocols/ViewModelProtocol.swift
  - Base protocol with isLoading, errorMessage
  - MainActor annotation
  - handleError method

- [ ] Create Core/DI/DIContainer.swift
  - Singleton container
  - register method for protocol-based registration
  - resolve method for dependency resolution

### Phase 2: Feature Implementation (Medium Priority)

- [ ] Create Feature/Models
  - Response models with Codable
  - Domain models mapping from responses

- [ ] Create Feature/Services
  - HomeServiceProtocol with service methods
  - HomeService conforming to ServiceProtocol
  - APIClient integration

- [ ] Create Feature/ViewModels
  - HomeViewModelProtocol with feature-specific methods
  - HomeViewModel conforming to ObservableObject and ViewModelProtocol
  - State management (data, loading, error)

- [ ] Create Feature/Views
  - HomeView with @StateObject
  - Binding to ViewModel
  - State-driven UI (loading, error, content states)

- [ ] Setup ContentView
  - Root navigation coordinator
  - Integration with DIContainer

### Phase 3: Testing (Medium Priority)

- [ ] Create Unit Tests for Network Layer
  - APIClient tests with mocked URLSession
  - Endpoint URL construction tests
  - NetworkError mapping tests

- [ ] Create Unit Tests for Services
  - Protocol-based mocking
  - Service method tests with mock APIClient
  - Response parsing tests

- [ ] Create Unit Tests for ViewModels
  - Observable state changes
  - Action handling tests
  - Error handling tests

## Implementation Order

1. **Foundation** → Network → Protocols → DI
2. **Feature** → Models → Services → ViewModels → Views
3. **Testing** → APIClient → Services → ViewModels

## Key Architecture Decisions

### Protocol-Oriented Programming
- All services follow `ServiceProtocol`
- All ViewModels follow `ViewModelProtocol`
- Enables easy testing with protocol-based mocking

### Async/Await
- Modern concurrency in APIClient
- Clean async/await syntax throughout
- MainActor for UI updates

### Dependency Injection
- Protocol-based registration
- Easy to swap implementations for testing
- Centralized service management

### State-Driven UI
- SwiftUI with ObservableObject
- Loading, error, and content states
- Reactive UI updates

## Testing Strategy

- **Network Layer**: Mock URLSession, verify URL construction, error handling
- **Services**: Protocol mocks, verify APIClient calls, response parsing
- **ViewModels**: Verify state changes, action handling, error propagation

## Notes

- All files follow Swift naming conventions
- Code comments minimal (unless asked)
- Protocol-first design for testability
- Swift concurrency best practices
- Modern iOS 16+ features
