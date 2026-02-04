# Agent Guidelines for DexLens

## Build Commands

```bash
# Build the project
xcodebuild -project DexLens.xcodeproj -scheme DexLens build

# Build for iOS Simulator
xcodebuild -project DexLens.xcodeproj -scheme DexLens -destination 'platform=iOS Simulator,name=iPhone 16' build

# Clean build
xcodebuild -project DexLens.xcodeproj -scheme DexLens clean
```

## Test Commands

```bash
# Run all tests
xcodebuild -project DexLens.xcodeproj -scheme DexLens test -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific test (Swift Testing framework)
xcodebuild -project DexLens.xcodeproj -scheme DexLens test -only-testing:DexLensTests/DexLensTests/example -destination 'platform=iOS Simulator,name=iPhone 16'

# Run tests matching pattern
xcodebuild -project DexLens.xcodeproj -scheme DexLens test -only-testing:DexLensTests/<TestTarget>/<TestClass>/<testMethod>
```

## Code Style Guidelines

### Imports
- Group imports: Foundation first, then SwiftUI, then Combine, then project modules
- Use `@testable import DexLens` in test files only
- No wildcard imports

### Naming Conventions
- **Types**: PascalCase (e.g., `HomeViewModel`, `CoinResponse`)
- **Protocols**: Suffix with `Protocol` (e.g., `APIClientProtocol`, `HomeServiceProtocol`)
- **Methods/Variables**: camelCase (e.g., `fetchTopCoins`, `isLoading`)
- **ViewModels**: Suffix with `ViewModel` (e.g., `HomeViewModel`)
- **Services**: Suffix with `Service` (e.g., `HomeService`)
- **Private properties**: No underscore prefix (e.g., `private let service`)

### Architecture Patterns
- **MVVM**: Views → ViewModels → Services → Network
- **Protocol-Oriented**: Define protocols before implementations
- **Dependency Injection**: Use `DIContainer` for service registration/resolution
- **MainActor**: All ViewModels must be `@MainActor`
- **ObservableObject**: ViewModels conform to `ObservableObject` with `@Published` properties

### Error Handling
- Use custom `NetworkError` enum for network operations
- Use `async throws` for async operations
- Handle errors in ViewModels using `handleError(_:)` from `ViewModelProtocol`
- Provide meaningful error messages to users via `errorMessage` property

### Networking
- Use `APIClientProtocol` for all network requests
- Create endpoint enums conforming to `Endpoint` protocol
- Decode responses using `try await apiClient.fetch(endpoint:)`
- Map response models to domain models in Services

### SwiftUI Views
- Use `@StateObject` for ViewModels
- Use `.task` modifier for initial data loading
- Use `.refreshable` for pull-to-refresh functionality
- Support dark mode with proper color assets
- Use custom `textStyle()` modifier for typography

### Documentation
- Add documentation comments for public protocols and methods
- Include usage examples in documentation where helpful
- Document error conditions and thrown errors

### Testing
- Use Swift Testing framework (`import Testing`)
- Tests should be in `DexLensTests/` directory
- Use `#expect()` for assertions
- Mock dependencies using protocols

### File Organization
```
Features/<FeatureName>/
  Views/           - SwiftUI Views
  ViewModels/      - ViewModels + Protocols
  Services/        - Services + Protocols
Features/Models/
  Domain/          - Domain models (Coin, etc.)
  Response/        - API Response models
Core/
  Network/         - APIClient, Endpoint, NetworkError
  Protocols/       - ServiceProtocol, ViewModelProtocol
  DI/              - DIContainer
  Utilities/       - Helper classes (ImageCache, etc.)
```

### Code Formatting
- 4 spaces for indentation
- Max line length: 120 characters
- Place opening braces on same line
- Use trailing commas in multi-line collections
- Add blank lines between logical sections

### Git
- Do not commit unless explicitly asked
- Never commit API keys or secrets
- Do not use `git add -i` or interactive git commands
- Follow existing commit message style when committing
