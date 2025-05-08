//
//  Logger.swift
//  Spider
//
//  Created by Siva Sankar on 01/05/25.
//

import Foundation

public protocol NetworkSession {
    func execute(
        _ request: URLRequest,
        completion: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void
    )
    
    func execute(_ request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {
    public func execute(
        _ request: URLRequest,
        completion: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        let task = dataTask(with: request, completionHandler: completion)
        task.resume()
    }
    
    public func execute(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }
}
