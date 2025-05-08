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
           completion: @Sendable @escaping (Result<Data, NetworkError>) -> Void
       ) {
           let urlRequest = request.asURLRequest()
           
           session.execute(urlRequest) { data, response, error in
               if let error = error {
                   completion(.failure(.custom(error.localizedDescription)))
                   return
               }
               
               guard let httpResponse = response as? HTTPURLResponse else {
                   completion(.failure(.unknown))
                   return
               }
               
               switch httpResponse.statusCode {
               case 200...299:
                   guard let data = data else {
                       completion(.failure(.noData))
                       return
                   }
                   completion(.success(data))
               case 401:
                   completion(.failure(.unauthorized))
               case 500...599:
                   completion(.failure(.serverError))
               default:
                   completion(.failure(.requestFailed(statusCode: httpResponse.statusCode)))
               }
           }
       }
       
       public func performRequest<T: Decodable>(
           _ request: HTTPRequest,
           responseType: T.Type,
           decoder: JSONDecoder = JSONDecoder(),
           completion:@Sendable @escaping (Result<T, NetworkError>) -> Void
       ) {
           performRequest(request) { result in
               switch result {
               case .success(let data):
                   do {
                       let decodedObject = try decoder.decode(T.self, from: data)
                       completion(.success(decodedObject))
                   } catch {
                       completion(.failure(.decodingFailed))
                   }
               case .failure(let error):
                   completion(.failure(error))
               }
           }
       }
       
       // MARK: - Async/Await API
       
       public func performRequest(_ request: HTTPRequest) async -> Result<Data, NetworkError> {
           let urlRequest = request.asURLRequest()
           
           do {
               let (data, response) = try await session.execute(urlRequest)
               
               guard let httpResponse = response as? HTTPURLResponse else {
                   return .failure(.unknown)
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
               return .failure(.custom(error.localizedDescription))
           }
       }
       
       public func performRequest<T: Decodable>(
           _ request: HTTPRequest,
           responseType: T.Type,
           decoder: JSONDecoder = JSONDecoder()
       ) async -> Result<T, NetworkError> {
           let result = await performRequest(request)
           
           switch result {
           case .success(let data):
               do {
                   let decodedObject = try decoder.decode(T.self, from: data)
                   return .success(decodedObject)
               } catch {
                   return .failure(.decodingFailed)
               }
           case .failure(let error):
               return .failure(error)
           }
       }
}
