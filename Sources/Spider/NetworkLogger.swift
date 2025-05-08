//
//  File.swift
//  Spider
//
//  Created by Siva Sankar on 08/05/25.
//

import Foundation

// MARK: - NetworkLogger

public protocol NetworkLogger: Sendable {
    func log(message: String)
}

// MARK: - ConsoleLogger

public final class ConsoleLogger: NetworkLogger, @unchecked Sendable {
    private let lock = NSLock()
    private let prefix: String
    
    public init(prefix: String = "NetworkService") {
        self.prefix = prefix
    }
    
    public func log(message: String) {
        lock.lock()
        defer { lock.unlock() }
        print("\(prefix): \(message)")
    }
}
