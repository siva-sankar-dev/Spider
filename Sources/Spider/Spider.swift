import Foundation

/// A lightweight networking interface for making HTTP requests with support for both GCD and Swift Concurrency.
///
/// `Spider` provides a simplified API for network operations while internally delegating to a `NetworkProtocol`
/// implementation. This struct serves as the main entry point for using the Spider networking package.
///
/// Example usage:
/// ```swift
/// // Create with default configuration
/// let network = Spider()
///
/// // Make a simple GET request
/// try network.performRequest(HTTPRequest(urlString: "https://api.example.com/users")) { result in
///     switch result {
///     case .success(let data):
///         // Handle the data
///     case .failure(let error):
///         // Handle the error
///     }
/// }
/// ```
public struct Spider {
    /// The underlying network service that handles actual network operations.
    ///
    /// This property exposes the network implementation for advanced customization when needed.
    /// In most cases, you won't need to interact with this property directly.
    public let service: NetworkProtocol
    
    /// Creates a new Spider networking interface.
    ///
    /// - Parameter service: The network service implementation to use. Defaults to a standard
    ///   `NetworkService` instance which uses `URLSession.shared` internally.
    ///
    /// You can provide custom network service implementations for specialized behaviors or testing:
    /// ```swift
    /// // For testing with mock responses
    /// let mockService = MockNetworkService()
    /// let testNetwork = Spider(service: mockService)
    ///
    /// // For custom URLSession configuration
    /// let customConfig = URLSessionConfiguration.default
    /// customConfig.timeoutIntervalForRequest = 60
    /// let customSession = URLSession(configuration: customConfig)
    /// let customService = NetworkService(session: customSession)
    /// let network = Spider(service: customService)
    /// ```
    public init(service: NetworkProtocol = NetworkService()) {
        self.service = service
    }
    
    // MARK: - Data API
    
    /// Performs an HTTP request and provides the raw response data using GCD completion handlers.
    ///
    /// - Parameters:
    ///   - request: The HTTP request to perform.
    ///   - completion: A closure that receives either the raw response data or an error.
    ///
    /// Example:
    /// ```swift
    /// let request = try HTTPRequest(urlString: "https://api.example.com/data")
    /// spider.performRequest(request) { result in
    ///     switch result {
    ///     case .success(let data):
    ///         print("Received \(data.count) bytes")
    ///     case .failure(let error):
    ///         print("Request failed: \(error.localizedDescription)")
    ///     }
    /// }
    /// ```
    public func performRequest(
        _ request: HTTPRequest,
        completion: @Sendable @escaping (Result<Data, NetworkError>) -> Void
    ) {
        service.performRequest(request, completion: completion)
    }
    
    /// Performs an HTTP request and provides the raw response data using Swift Concurrency.
    ///
    /// - Parameter request: The HTTP request to perform.
    /// - Returns: A result containing either the raw response data or an error.
    ///
    /// Example:
    /// ```swift
    /// do {
    ///     let request = try HTTPRequest(urlString: "https://api.example.com/data")
    ///     let result = await spider.performRequest(request)
    ///
    ///     switch result {
    ///     case .success(let data):
    ///         print("Received \(data.count) bytes")
    ///     case .failure(let error):
    ///         print("Request failed: \(error.localizedDescription)")
    ///     }
    /// } catch {
    ///     print("Failed to create request: \(error)")
    /// }
    /// ```
    public func performRequest(_ request: HTTPRequest) async -> Result<Data, NetworkError> {
        await service.performRequest(request)
    }
    
    // MARK: - Decodable API
    
    /// Performs an HTTP request and automatically decodes the response into a specified type using GCD completion handlers.
    ///
    /// - Parameters:
    ///   - request: The HTTP request to perform.
    ///   - responseType: The type to decode the response into. Must conform to `Decodable`.
    ///   - decoder: The JSON decoder to use for decoding. Defaults to a standard `JSONDecoder`.
    ///   - completion: A closure that receives either the decoded object or an error.
    ///
    /// Example:
    /// ```swift
    /// struct User: Decodable {
    ///     let id: Int
    ///     let name: String
    /// }
    ///
    /// let request = try HTTPRequest(urlString: "https://api.example.com/users/1")
    /// spider.performRequest(request, responseType: User.self) { result in
    ///     switch result {
    ///     case .success(let user):
    ///         print("Received user: \(user.name)")
    ///     case .failure(let error):
    ///         print("Request failed: \(error.localizedDescription)")
    ///     }
    /// }
    /// ```
    public func performRequest<T: Decodable>(
        _ request: HTTPRequest,
        responseType: T.Type,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @Sendable @escaping (Result<T, NetworkError>) -> Void
    ) {
        service.performRequest(request, responseType: responseType, decoder: decoder, completion: completion)
    }
    
    /// Performs an HTTP request and automatically decodes the response into a specified type using Swift Concurrency.
    ///
    /// - Parameters:
    ///   - request: The HTTP request to perform.
    ///   - responseType: The type to decode the response into. Must conform to `Decodable`.
    ///   - decoder: The JSON decoder to use for decoding. Defaults to a standard `JSONDecoder`.
    /// - Returns: A result containing either the decoded object or an error.
    ///
    /// Example:
    /// ```swift
    /// struct User: Decodable {
    ///     let id: Int
    ///     let name: String
    /// }
    ///
    /// do {
    ///     let request = try HTTPRequest(urlString: "https://api.example.com/users/1")
    ///     let result = await spider.performRequest(request, responseType: User.self)
    ///
    ///     switch result {
    ///     case .success(let user):
    ///         print("Received user: \(user.name)")
    ///     case .failure(let error):
    ///         print("Request failed: \(error.localizedDescription)")
    ///     }
    /// } catch {
    ///     print("Failed to create request: \(error)")
    /// }
    /// ```
    public func performRequest<T: Decodable>(
        _ request: HTTPRequest,
        responseType: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) async -> Result<T, NetworkError> {
        await service.performRequest(request, responseType: responseType, decoder: decoder)
    }
}
