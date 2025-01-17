//
//  LocalCountryDataSourceImpl.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// MARK: - Local Data Source Implementation
public final class LocalCountryDataSourceImpl: LocalCountryDataSource {
    private let storage: PersistentStorage
    private let storageKey = "stored_countries"
    
    public init(storage: PersistentStorage = UserDefaultsStorage()) {
        self.storage = storage
    }
    
    public func fetch() async throws -> [CountryDTO] {
        guard await exists() else {
            throw NetworkError.notFound
        }
        return try await storage.fetch(forKey: storageKey)
    }
    
    public func save(_ items: [CountryDTO]) async throws {
        try await storage.save(items, forKey: storageKey)
    }
    
    public func clear() async throws {
        try await storage.remove(forKey: storageKey)
    }
    
    public func exists() async -> Bool {
        return await storage.exists(forKey: storageKey)
    }
}
