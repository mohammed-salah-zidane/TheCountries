//
//  CachePolicy.swift
//  Core
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// MARK: - Cache Policy Protocol
public protocol CachePolicyProtocol {
    /// Checks if the cached data is still valid
    /// - Parameter lastUpdateTime: The timestamp of the last cache update
    /// - Returns: Boolean indicating if cache is valid
    func isValid(lastUpdateTime: Date) -> Bool
    
    /// Gets the cache expiration time
    var expirationTime: TimeInterval { get }
}

// MARK: - Default Cache Policy
public struct DefaultCachePolicy: CachePolicyProtocol {
    /// Default cache expiration time (1 hour)
    public let expirationTime: TimeInterval
    
    public init(expirationTime: TimeInterval = 3600) {
        self.expirationTime = expirationTime
    }
    
    public func isValid(lastUpdateTime: Date) -> Bool {
        let currentTime = Date()
        let timeDifference = currentTime.timeIntervalSince(lastUpdateTime)
        return timeDifference <= expirationTime
    }
}
