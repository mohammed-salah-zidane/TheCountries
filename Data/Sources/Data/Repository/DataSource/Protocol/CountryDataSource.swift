//
//  CountryDataSource.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation
import Core

// Make protocols public
public protocol CountryDataSource {
    /// Fetches countries from the data source
    /// - Returns: Array of CountryDTO
    /// - Throws: Error if the fetch operation fails
    func fetch() async throws -> [CountryDTO]
}

public protocol RemoteCountryDataSource: CountryDataSource {}

public protocol LocalCountryDataSource: CountryDataSource {
    /// Saves countries to local storage
    /// - Parameter items: Array of CountryDTO to save
    /// - Throws: Error if the save operation fails
    func save(_ items: [CountryDTO]) async throws
    
    /// Clears all stored countries
    /// - Throws: Error if the clear operation fails
    func clear() async throws
    
    /// Checks if any countries exist in storage
    /// - Returns: Boolean indicating if data exists
    func exists() async -> Bool
    
    /// Gets the last update time of the stored data
    /// - Returns: Optional Date of the last update
    func getLastUpdateTime() async -> Date?
}

public extension LocalCountryDataSource {
    func exists() async -> Bool {
        do {
            let items = try await fetch()
            return !items.isEmpty
        } catch {
            return false
        }
    }
    
    func getLastUpdateTime() async -> Date? {
        return nil
    }
}
