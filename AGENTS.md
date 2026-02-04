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

## SwiftFormat Commands

```bash
# Format all Swift files in project
swiftformat .

# Check formatting without making changes
swiftformat --lint .

# Preview formatting changes
swiftformat --dry-run .

# Format specific file
swiftformat path/to/file.swift

# Format with verbose output
swiftformat --verbose .

# Lint with detailed output
swiftformat --lint --verbose .
```

## AI Assistant Workflow (REQUIRED)

### Post-Build/Edit Checklist (MANDATORY)

After completing **ANY** development work (builds, code edits, or changes), AI assistants MUST:

1. **Run SwiftFormat lint to check code formatting:**
   ```bash
   swiftformat --lint .
   ```

2. **Report results:**
   - If no issues: Display "✅ SwiftFormat check passed"
   - If issues found: Report them as warnings with file names and rule violations
   - **NEVER** auto-fix formatting issues
   - **NEVER** modify code without explicit user instruction
   - Suggest running `swiftformat .` only if user asks how to fix

3. **Example warning format:**
   ```
   ⚠️  SwiftFormat found formatting issues in X file(s):
   - FileName.swift: rule1, rule2
   - OtherFile.swift: rule3
   
   Run `swiftformat .` to auto-fix if desired.
   ```

### When to Run
- After completing builds
- After making code edits
- Before declaring work "complete"
- Any time code changes are made

### Important Rules
- This is a **CHECK ONLY** - no automatic fixes
- Warnings should not block other work
- User decides whether to run formatter
- Applies to all Swift code changes

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
- **Use custom `textStyle()` modifier for ALL text styling** - NEVER use `.font()` or `.foregroundStyle()` directly on Text
  - Available in `Core/DesignSystem/View+TextStyles.swift`
  - Example: `Text("Title").textStyle(.headline, color: .textPrimary)`
  - TextStyle options: `.largeTitle`, `.title1`, `.title2`, `.title3`, `.headline`, `.body`, `.bodyBold`, `.callout`, `.subheadline`, `.subheadlineBold`, `.footnote`, `.footnoteBold`, `.caption1`, `.caption2`
  - ColorStyle options: `.primary`, `.primaryMuted`, `.success`, `.error`, `.warning`, `.textPrimary`, `.textSecondary`, `.white`
  - This ensures consistent typography (Roboto font family) and colors across the app

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
