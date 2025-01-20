//
//  CountryDataSource.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation
import Core

// Make protocols public
public protocol CountryDataSource: Sendable {
    /// Fetches countries from the data source
    /// - Returns: Array of CountryDTO
    /// - Throws: Error if the fetch operation fails
    func fetch() async throws -> [CountryDTO]
}

public protocol RemoteCountryDataSource: CountryDataSource {
    
    /// search country from the data source
    /// - Returns: Array of CountryDTO
    /// - Throws: Error if the fetch operation fails
    func searchCountry(query: String) async throws -> [CountryDTO]
}

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
    
    /// Fetches selected countries from local storage
    /// - Returns: Array of selected CountryDTO
    /// - Throws: Error if the fetch operation fails
    func fetchSelectedCountries() async throws -> [CountryDTO]
    
    /// Saves selected countries to local storage
    /// - Parameter items: Array of CountryDTO to save as selected
    /// - Throws: Error if the save operation fails
    func saveSelectedCountries(_ items: [CountryDTO]) async throws
    
    /// Clears all selected countries from storage
    /// - Throws: Error if the clear operation fails
    func clearSelectedCountries() async throws
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
