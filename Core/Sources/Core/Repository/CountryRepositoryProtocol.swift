//
//  CountryRepositoryProtocol.swift
//  Core
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// MARK: - Repository Protocol
public protocol CountryRepositoryProtocol: Sendable {
    /// Fetches all countries based on the specified data source policy
    /// - Parameter policy: Determines the data source strategy
    /// - Returns: Array of Country domain models
    /// - Throws: CoreError if the operation fails
    func fetchAllCountries(policy: DataSourcePolicy) async throws -> [Country]
    
    /// Searches countries with the given query
    /// - Parameter query: Search term
    /// - Returns: List of matching countries
    /// - Throws: CoreError if the operation fails
    func searchCountries(withQuery query: String) async throws -> [Country]
    
    /// Updates local storage with the provided countries
    /// - Parameter countries: Array of Country domain models to store
    /// - Throws: CoreError.storageError if the operation fails
    func updateLocalStorage(with countries: [Country]) async throws
    
    /// Clears all stored countries from local storage
    /// - Throws: CoreError.storageError if the operation fails
    func clearLocalStorage() async throws
    
    /// Checks if local storage has valid data
    /// - Returns: Boolean indicating if valid data exists
    func hasValidLocalData() async -> Bool
}

// MARK: - Default Implementation
public extension CountryRepositoryProtocol {
    func fetchAllCountries() async throws -> [Country] {
        return try await fetchAllCountries(policy: .default)
    }
    
    func hasValidLocalData() async -> Bool {
        return false // Default implementation returns false
    }
}
