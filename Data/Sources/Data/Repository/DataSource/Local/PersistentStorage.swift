//
//  PersistentStorage.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation
import Core

// MARK: - Persistent Storage Protocol
public protocol PersistentStorage: Sendable {
    /// Saves an encodable item to storage
    /// - Parameters:
    ///   - item: The item to save
    ///   - key: The key to save under
    /// - Throws: CoreError if save fails
    func save<T: Encodable & Sendable>(_ item: T, forKey key: String) async throws
    
    /// Fetches a decodable item from storage
    /// - Parameter key: The key to fetch
    /// - Returns: The decoded item
    /// - Throws: CoreError if fetch fails
    func fetch<T: Decodable & Sendable>(forKey key: String) async throws -> T
    
    /// Removes an item from storage
    /// - Parameter key: The key to remove
    /// - Throws: CoreError if remove fails
    func remove(forKey key: String) async throws
    
    /// Checks if an item exists in storage
    /// - Parameter key: The key to check
    /// - Returns: Boolean indicating if item exists
    func exists(forKey key: String) async -> Bool
}

// MARK: - UserDefaults Storage Implementation
public actor UserDefaultsStorage: PersistentStorage {
    // Use nonisolated to avoid Sendable warnings since UserDefaults is thread-safe
    private let defaults: UserDefaults
    
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    public func save<T: Encodable & Sendable>(_ item: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(item)
        defaults.set(data, forKey: key)
    }
    
    public func fetch<T: Decodable & Sendable>(forKey key: String) async throws -> T {
        guard let data = defaults.data(forKey: key) else {
            throw CoreError.storageError("No data found for key: \(key)")
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func remove(forKey key: String) async throws {
        defaults.removeObject(forKey: key)
    }
    
    public func exists(forKey key: String) async -> Bool {
        return defaults.object(forKey: key) != nil
    }
}
