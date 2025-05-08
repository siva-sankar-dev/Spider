//
//  Services.swift
//  Spider
//
//  Created by Siva Sankar on 01/05/25.
//
import Foundation
public class NetworkService: NetworkProtocol {
    public let session: NetworkSession

    public init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }

    // MARK: - GCD API

    public func performRequest(
        _ request: HTTPRequest,
        logging: Bool = false,
        completion: @Sendable @escaping (Result<Data, NetworkError>) -> Void
    ) {
        let urlRequest = request.asURLRequest()

        if logging {
            print("🚀 Performing request to: \(urlRequest.url?.absoluteString ?? "Invalid URL")")
            print("🔸 Method: \(urlRequest.httpMethod ?? "N/A")")
            print("🔸 Headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
            if let body = urlRequest.httpBody,
               let bodyString = String(data: body, encoding: .utf8) {
                print("🔸 Body: \(bodyString)")
            }
        }

        session.execute(urlRequest) { data, response, error in
            if let error = error {
                if logging { print("❌ Request error: \(error.localizedDescription)") }
                completion(.failure(.custom(error.localizedDescription)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                if logging { print("⚠️ Invalid response type") }
                completion(.failure(.unknown))
                return
            }

            if logging {
                print("✅ Status code: \(httpResponse.statusCode)")
                print("📩 Headers: \(httpResponse.allHeaderFields)")
            }

            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    if logging { print("⚠️ No data received") }
                    completion(.failure(.noData))
                    return
                }
                if logging {
                    print("📦 Data received: \(data.count) bytes")
                    if let string = String(data: data, encoding: .utf8) {
                        print("📄 Response Body (UTF8):\n\(string)")
                    }
                }
                completion(.success(data))
            case 401:
                if logging { print("🔐 Unauthorized access") }
                completion(.failure(.unauthorized))
            case 500...599:
                if logging { print("🔥 Server error") }
                completion(.failure(.serverError))
            default:
                if logging { print("❗Request failed with status code: \(httpResponse.statusCode)") }
                completion(.failure(.requestFailed(statusCode: httpResponse.statusCode)))
            }
        }
    }

    public func performRequest<T: Decodable>(
        _ request: HTTPRequest,
        responseType: T.Type,
        decoder: JSONDecoder = JSONDecoder(),
        logging: Bool = false,
        completion:@Sendable @escaping (Result<T, NetworkError>) -> Void
    ) {
        performRequest(request, logging: logging) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    if logging { print("✅ Decoding success for type \(T.self)") }
                    completion(.success(decodedObject))
                } catch {
                    if logging {
                        print("❌ Decoding failed: \(error.localizedDescription)")
                        if let string = String(data: data, encoding: .utf8) {
                            print("🧾 Response Body for debugging:\n\(string)")
                        }
                    }
                    completion(.failure(.decodingFailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Async/Await API

    public func performRequest(_ request: HTTPRequest, logging: Bool = false) async -> Result<Data, NetworkError> {
        let urlRequest = request.asURLRequest()

        if logging {
            print("🚀 Async request to: \(urlRequest.url?.absoluteString ?? "Invalid URL")")
            print("🔸 Method: \(urlRequest.httpMethod ?? "N/A")")
            print("🔸 Headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
            if let body = urlRequest.httpBody,
               let bodyString = String(data: body, encoding: .utf8) {
                print("🔸 Body: \(bodyString)")
            }
        }

        do {
            let (data, response) = try await session.execute(urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                if logging { print("⚠️ Invalid HTTPURLResponse") }
                return .failure(.unknown)
            }

            if logging {
                print("✅ Status: \(httpResponse.statusCode)")
                print("📩 Headers: \(httpResponse.allHeaderFields)")
                print("📦 Data received: \(data.count) bytes")
                if let string = String(data: data, encoding: .utf8) {
                    print("📄 Response Body:\n\(string)")
                }
            }

            switch httpResponse.statusCode {
            case 200...299:
                return .success(data)
            case 401:
                return .failure(.unauthorized)
            case 500...599:
                return .failure(.serverError)
            default:
                return .failure(.requestFailed(statusCode: httpResponse.statusCode))
            }
        } catch {
            if logging { print("❌ Async request error: \(error.localizedDescription)") }
            return .failure(.custom(error.localizedDescription))
        }
    }

    public func performRequest<T: Decodable>(
        _ request: HTTPRequest,
        responseType: T.Type,
        decoder: JSONDecoder = JSONDecoder(),
        logging: Bool = false
    ) async -> Result<T, NetworkError> {
        let result = await performRequest(request, logging: logging)

        switch result {
        case .success(let data):
            do {
                let decoded = try decoder.decode(T.self, from: data)
                if logging { print("✅ Async decoding success for type \(T.self)") }
                return .success(decoded)
            } catch {
                if logging {
                    print("❌ Async decoding failed: \(error)")
                    if let string = String(data: data, encoding: .utf8) {
                        print("🧾 Response Body:\n\(string)")
                    }
                }
                return .failure(.decodingFailed)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}

