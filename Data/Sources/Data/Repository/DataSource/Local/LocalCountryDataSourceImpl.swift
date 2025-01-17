//
//  LocalCountryDataSourceImpl.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation
import Core

// MARK: - Local Data Source Implementation
@globalActor public actor LocalStorageActor {
    public static let shared = LocalStorageActor()
    private init() {}
}

// MARK: - Local Data Source Protocol Extension
extension LocalCountryDataSource {
    // Default empty implementations for optional methods
    public func cleanup() {}
    public func releaseMemory() {}
    public func prepareForBackground() {}
    public func restoreForForeground() {}
}

// MARK: - Local Country Data Source Implementation
public final class LocalCountryDataSourceImpl: LocalCountryDataSource, ResourceManageable {
    // MARK: - Properties
    
    private let storage: PersistentStorage
    private let storageKey = "stored_countries"
    private let lastUpdateKey = "countries_last_update"
    
    private actor Cache {
        var data: [CountryDTO]?
        
        init() {
            self.data = nil
        }
        
        func getData() -> [CountryDTO]? { data }
        func setData(_ newData: [CountryDTO]?) { data = newData }
        func clearData() { data = nil }
    }
    
    private let cache: Cache
    
    // MARK: - Initialization
    public init(storage: PersistentStorage = UserDefaultsStorage()) {
        self.storage = storage
        self.cache = Cache()
    }
    
    public func fetch() async throws -> [CountryDTO] {
        if let cached = await cache.getData() {
            return cached
        }
        
        guard await exists() else {
            throw CoreError.dataSourceError("No local data found")
        }
        
        let countries: [CountryDTO] = try await storage.fetch(forKey: storageKey)
        await cache.setData(countries)
        return countries
    }
    
    public func save(_ items: [CountryDTO]) async throws {
        try await storage.save(items, forKey: storageKey)
        try await storage.save(Date(), forKey: lastUpdateKey)
        await cache.setData(items)
    }
    
    public func clear() async throws {
        try await storage.remove(forKey: storageKey)
        try await storage.remove(forKey: lastUpdateKey)
        await cache.clearData()
    }
    
    public func exists() async -> Bool {
        return await storage.exists(forKey: storageKey)
    }
    
    public func getLastUpdateTime() async -> Date? {
        return try? await storage.fetch(forKey: lastUpdateKey)
    }
    
    public nonisolated func cleanup() {
        let cache = self.cache // Capture reference to avoid data races
        Task { await cache.clearData() }
    }
    
    public nonisolated func releaseMemory() {
        let cache = self.cache // Capture reference to avoid data races
        Task { await cache.clearData() }
    }
    
    public nonisolated func prepareForBackground() {
        let (cache, storage, storageKey, lastUpdateKey) = (self.cache, self.storage, self.storageKey, self.lastUpdateKey)
        Task {
            if let cached = await cache.getData() {
                try? await storage.save(cached, forKey: storageKey)
                try? await storage.save(Date(), forKey: lastUpdateKey)
            }
            await cache.clearData()
        }
    }
    
    public nonisolated func restoreForForeground() {
        let cache = self.cache // Capture reference to avoid data races
        Task { await cache.clearData() }
    }
}
