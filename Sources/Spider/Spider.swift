import Foundation

public struct SpiderNet {
    // The service property provides the actual networking functionality
    public let service: NetworkProtocol
    
    // Default initializer uses URLSession.shared
    public init(service: NetworkProtocol = NetworkService()) {
        self.service = service
    }
    
    // MARK: - Data API Forwarding
    
    // GCD style
    public func performRequest(
        _ request: HTTPRequest,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        service.performRequest(request, completion: completion)
    }
    
    // Swift Concurrency style
    public func performRequest(_ request: HTTPRequest) async -> Result<Data, NetworkError> {
        await service.performRequest(request)
    }
    
    // MARK: - Decodable API Forwarding
    
    // GCD style
    public func performRequest<T: Decodable>(
        _ request: HTTPRequest,
        responseType: T.Type,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        service.performRequest(request, responseType: responseType, decoder: decoder, completion: completion)
    }
    
    // Swift Concurrency style
    public func performRequest<T: Decodable>(
        _ request: HTTPRequest,
        responseType: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) async -> Result<T, NetworkError> {
        await service.performRequest(request, responseType: responseType, decoder: decoder)
    }
}

