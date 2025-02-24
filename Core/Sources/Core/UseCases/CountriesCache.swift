//
//  CountriesCache.swift
//  Core
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// MARK: - Countries Cache Protocol
public protocol CountriesCacheProtocol: ResourceManageable {
    /// Retrieves countries from cache
    /// - Returns: Optional array of cached countries
    func getCountries() -> [Country]?
    
    /// Stores countries in cache
    /// - Parameter countries: The countries to cache
    func store(_ countries: [Country])
    
    /// Clears the cache
    func clear()
}

// MARK: - Countries Cache Implementation
public final class CountriesCache: CountriesCacheProtocol {
    private var cache: [Country]?
    private let queue = DispatchQueue(label: "com.countries.cache", qos: .userInitiated)
    
    public init() {}
    
    public func getCountries() -> [Country]? {
        queue.sync { cache }
    }
    
    public func store(_ countries: [Country]) {
        queue.sync { cache = countries }
    }
    
    public func clear() {
        queue.sync { cache = nil }
    }
    
    // MARK: - ResourceManageable Implementation
    
    public func cleanup() {
        clear()
    }
    
    public func releaseMemory() {
        clear()
    }
    
    public func prepareForBackground() {
        clear()
    }
    
    public func restoreForForeground() {}
}

