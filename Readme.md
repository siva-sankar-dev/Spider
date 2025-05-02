# Spider

A lightweight, protocol-oriented network layer for Swift applications. Spider provides a flexible and testable networking foundation for both UIKit and SwiftUI applications, with support for both GCD completion handlers and modern Swift Concurrency.

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Platform](https://img.shields.io/badge/platforms-iOS%20|%20macOS%20|%20watchOS%20|%20tvOS-lightgrey.svg)](https://developer.apple.com/swift/)
[![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- **Protocol-Oriented Design** - Clean, testable architecture following Swift best practices
- **Flexible API** - Choose between GCD completion handlers or modern Swift Concurrency (async/await)
- **Generic Response Handling** - Get typed models with automatic decoding or raw data
- **Comprehensive Error Handling** - Detailed error cases for network issues
- **Lightweight & Dependency-Free** - No external dependencies required
- **Highly Testable** - Designed with testing in mind
- **iOS 13+ & macOS 10.15+** - Support for modern Apple platforms

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/siva-sankar-dev/Spider", from: "1.0.0")
]
```

Or add it directly through Xcode:
1. File > Swift Packages > Add Package Dependency
2. Enter the repository URL: `https://github.com/yourusername/Spider.git`
3. Specify the version requirements

## Quick Start Guide

### Basic GET Request

```swift
import Spider

// Create a network instance
let network = Spider()

// Create a request
do {
    let request = try HTTPRequest(urlString: "https://api.example.com/users")
    
    // Using completion handlers (GCD)
    network.performRequest(request) { result in
        switch result {
        case .success(let data):
            print("Received \(data.count) bytes")
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // Or using async/await
    Task {
        let result = await network.performRequest(request)
        // Handle result
    }
} catch {
    print("Invalid request: \(error)")
}
```

### Decoding Models Automatically

```swift
struct User: Decodable {
    let id: Int
    let name: String
    let email: String
}

do {
    let request = try HTTPRequest(urlString: "https://api.example.com/users/1")
    
    // Using completion handlers
    network.performRequest(request, responseType: User.self) { result in
        switch result {
        case .success(let user):
            print("User: \(user.name)")
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // Or using async/await
    Task {
        let result = await network.performRequest(request, responseType: User.self)
        // Handle result
    }
} catch {
    print("Invalid request: \(error)")
}
```

### POST Request with JSON Body

```swift
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct AuthResponse: Decodable {
    let token: String
    let userId: Int
}

do {
    let loginData = LoginRequest(email: "user@example.com", password: "password123")
    
    // Convenient POST with JSON helper
    let request = try HTTPRequest.post(
        urlString: "https://api.example.com/login",
        json: loginData
    )
    
    // Send the request
    network.performRequest(request, responseType: AuthResponse.self) { result in
        // Handle result
    }
} catch {
    print("Invalid request: \(error)")
}
```

## Architecture

Spider follows a clean, protocol-oriented architecture:

### Core Components

- **HTTPRequest** - Configurable request object
- **NetworkProtocol** - Core networking protocol
- **NetworkService** - Default implementation
- **NetworkSession** - URLSession abstraction

### Error Handling

Spider provides a comprehensive `NetworkError` enum:

```swift
public enum NetworkError: Error, Equatable {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed
    case noData
    case unauthorized
    case serverError
    case custom(String)
    case unknown
}
```

## Advanced Usage

### Custom Configuration

```swift
// Create a custom URLSession
let config = URLSessionConfiguration.default
config.timeoutIntervalForRequest = 30
config.requestCachePolicy = .reloadIgnoringLocalCacheData
let customSession = URLSession(configuration: config)

// Create a custom network service
let customNetworkService = NetworkService(session: customSession)

// Create Spider with custom service
let network = Spider(service: customNetworkService)
```

### Custom Headers

```swift
let request = try HTTPRequest(
    urlString: "https://api.example.com/secure-endpoint",
    method: .get,
    headers: [
        .authorization(bearerToken: "your-token-here"),
        .accept(value: "application/json"),
        HTTPHeader(name: "Custom-Header", value: "Custom-Value")
    ]
)
```

### Request with Query Parameters

```swift
var components = URLComponents(string: "https://api.example.com/search")!
components.addQueryItems([
    "q": "search term",
    "page": "1",
    "limit": "20"
])

let request = try HTTPRequest(
    urlString: components.url!.absoluteString
)
```

### File Upload

```swift
let fileData = try Data(contentsOf: fileURL)

let request = HTTPRequest(
    url: URL(string: "https://api.example.com/upload")!,
    method: .post,
    headers: [.contentType(value: "application/octet-stream")],
    body: fileData
)
```

## Testing

Spider is designed with testing in mind. The protocol-oriented architecture allows for easy mocking:

```swift
// Create a mock session for testing
let mockSession = MockNetworkSession(
    mockData: responseData,
    mockResponse: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil),
    mockError: nil
)

// Inject the mock into the service
let mockService = NetworkService(session: mockSession)
let testNetwork = Spider(service: mockService)

// Test with the mocked network
testNetwork.performRequest(request) { result in
    // Assert on result
}
```

## Best Practices

1. **Dependency Injection** - Inject the Spider instance into your services or view models
2. **Error Handling** - Always handle network errors appropriately
3. **Cancellation** - For long-running tasks, implement cancellation logic
4. **Retry Logic** - Consider implementing retry logic for transient failures
5. **Logging** - Add proper logging for network requests in development

## Integration Examples

### SwiftUI Integration

```swift
class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let network: Spider
    
    init(network: Spider = Spider()) {
        self.network = network
    }
    
    func fetchUser(id: Int) async {
        isLoading = true
        
        do {
            let request = try HTTPRequest(urlString: "https://api.example.com/users/\(id)")
            let result = await network.performRequest(request, responseType: User.self)
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let user):
                    self.user = user
                case .failure(let error):
                    self.error = error
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.error = error
            }
        }
    }
}
```

### UIKit Integration

```swift
class UserViewController: UIViewController {
    private let network = Spider()
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser(id: 1)
    }
    
    private func fetchUser(id: Int) {
        do {
            let request = try HTTPRequest(urlString: "https://api.example.com/users/\(id)")
            
            network.performRequest(request, responseType: User.self) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let user):
                    self.user = user
                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.showError(error)
                    }
                }
            }
        } catch {
            showError(error)
        }
    }
    
    private func updateUI() {
        // Update UI with user data
    }
    
    private func showError(_ error: Error) {
        // Show error alert
    }
}
```

## Common HTTP Status Code Handling

Spider automatically converts common HTTP status codes to appropriate errors:

| Status Code | Error |
|-------------|-------|
| 401 | `.unauthorized` |
| 500-599 | `.serverError` |
| Other non-2xx | `.requestFailed(statusCode:)` |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Requirements

- iOS 13.0+ / macOS 10.15+ / watchOS 6.0+ / tvOS 13.0+
- Swift 5.5+
- Xcode 13.0+

## License

Spider is available under the MIT license. See the LICENSE file for more info.

## Acknowledgements

- Inspired by modern Swift best practices and protocol-oriented programming
- Thanks to the Swift community for feedback and contributions
