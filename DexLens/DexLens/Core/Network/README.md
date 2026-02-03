# Network Layer

Provides a protocol-based, async/await networking solution for API requests.

## Overview

The network layer is built with protocol-oriented programming principles, enabling easy testing and mocking. It consists of three main components:

### Components

| Component | Description |
|-----------|-------------|
| `NetworkError` | Type-safe error handling with localized messages |
| `Endpoint` | Protocol for defining API endpoints |
| `APIClient` | Generic async client for fetching and decoding data |

## Usage

### 1. Define an Endpoint

```swift
struct UsersEndpoint: Endpoint {
    var baseURL: URL = URL(string: "https://api.example.com")!
    var path: String = "/users"
    var method: HTTPMethod = .get
    var headers: [String: String]? = ["Accept": "application/json"]
    var parameters: [String: Any]? = nil
}
```

### 2. Create a Response Model

```swift
struct User: Decodable {
    let id: Int
    let name: String
    let email: String
}
```

### 3. Fetch Data

```swift
let client = APIClient()
let users: [User] = try await client.fetch(endpoint: UsersEndpoint())
```

### 4. Handle Errors

```swift
do {
    let users: [User] = try await client.fetch(endpoint: UsersEndpoint())
} catch let error as NetworkError {
    print(error.errorDescription)
}
```

## Error Types

- `invalidURL`: The endpoint URL could not be constructed
- `invalidResponse`: The response was not an HTTPURLResponse
- `serverError(statusCode:)`: Server returned a non-2xx status code
- `decodingError(Error)`: Failed to decode the response data
- `networkError(Error)`: Underlying network error

## HTTP Methods

Supported HTTP methods:
- `.get`
- `.post`
- `.put`
- `.patch`
- `.delete`

## Features

- **Protocol-based**: Easy to mock for testing
- **Type-safe**: Generic decoding with Codable
- **Async/Await**: Modern Swift concurrency
- **Error Handling**: Comprehensive error types with localized messages
- **Flexible**: Supports query parameters (GET) and body parameters (POST/PUT/PATCH/DELETE)
