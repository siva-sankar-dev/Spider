//
//  HttpMethod.swift
//  Spider
//
//  Created by Siva Sankar on 01/05/25.
//

import Foundation

/// Enum representing standard HTTP methods.
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}


public struct HTTPHeader {
    public let name: String
    public let value: String
    
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
    
    public static func contentType(value: String) -> HTTPHeader {
        HTTPHeader(name: "Content-Type", value: value)
    }
    
    public static func accept(value: String) -> HTTPHeader {
        HTTPHeader(name: "Accept", value: value)
    }
    
    public static func authorization(bearerToken: String) -> HTTPHeader {
        HTTPHeader(name: "Authorization", value: "Bearer \(bearerToken)")
    }
}

public struct HTTPRequest {
    public let url: URL
    public let method: HTTPMethod
    public let headers: [HTTPHeader]
    public let body: Data?
    public let cachePolicy: URLRequest.CachePolicy
    public let timeoutInterval: TimeInterval
    
    public init(
        url: URL,
        method: HTTPMethod = .get,
        headers: [HTTPHeader] = [],
        body: Data? = nil,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 30.0
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
    }
    
    public init(
        urlString: String,
        method: HTTPMethod = .get,
        headers: [HTTPHeader] = [],
        body: Data? = nil,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 30.0
    ) throws {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        self.init(
            url: url,
            method: method,
            headers: headers,
            body: body,
            cachePolicy: cachePolicy,
            timeoutInterval: timeoutInterval
        )
    }
    
    // Helper method to create POST request with JSON body
    public static func post(
        urlString: String,
        json: Encodable,
        additionalHeaders: [HTTPHeader] = [],
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> HTTPRequest {
        let body = try encoder.encode(json)
        var headers = additionalHeaders
        headers.append(.contentType(value: "application/json"))
        
        return try HTTPRequest(
            urlString: urlString,
            method: .post,
            headers: headers,
            body: body
        )
    }
    
    // Convert to URLRequest
    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.cachePolicy = cachePolicy
        request.timeoutInterval = timeoutInterval
        
        headers.forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.name)
        }
        
        request.httpBody = body
        return request
    }
}

