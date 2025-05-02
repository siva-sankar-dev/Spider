//
//  NetworkError.swift
//  Spider
//
//  Created by Siva Sankar on 01/05/25.
//
import Foundation

public enum NetworkError: Error, Equatable {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed
    case noData
    case unauthorized
    case serverError
    case custom(String)
    case unknown
    
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .requestFailed(let statusCode):
            return "Request failed with status code: \(statusCode)"
        case .decodingFailed:
            return "Failed to decode response"
        case .noData:
            return "No data received"
        case .unauthorized:
            return "Authentication required"
        case .serverError:
            return "Server error occurred"
        case .custom(let message):
            return message
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

