//
//  Requestable.swift
//  Spider
//
//  Created by Siva Sankar on 01/05/25.
//

import Foundation

public protocol NetworkProtocol {
    var session: NetworkSession { get }
    
    // GCD style APIs
    func performRequest(
        _ request: HTTPRequest,
        logging: Bool,
        completion: @Sendable @escaping (Result<Data, NetworkError>) -> Void
    )
    func performRequest<T: Decodable>(
        _ request: HTTPRequest,
        responseType: T.Type,
        decoder: JSONDecoder,
        logging: Bool,
        completion: @Sendable @escaping (Result<T, NetworkError>) -> Void
    )
    
    // Async/await style APIs
    func performRequest(
        _ request: HTTPRequest,
        logging: Bool,
    ) async -> Result<Data, NetworkError>
    func performRequest<T: Decodable>(
        _ request: HTTPRequest,
        responseType: T.Type,
        decoder: JSONDecoder,
        logging: Bool,
    ) async -> Result<T, NetworkError>
}
