//
//  RemoteCountryDataSourceImpl.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// MARK: - Remote Data Source Implementation

/// Implementation of RemoteCountryDataSource
/// Marked as @MainActor since it works with MainActor-isolated NetworkClient
public final class RemoteCountryDataSourceImpl: RemoteCountryDataSource {
    /// Network client for making API requests
    private let networkClient: NetworkClientProtocol
    
    /// Initializes the data source with a network client
    /// - Parameter networkClient: The network client to use for API requests
    public init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    /// Fetches countries from the remote API
    /// - Returns: Array of CountryDTO objects that are Sendable
    /// - Throws: NetworkError if the request fails
    public func fetch() async throws -> [CountryDTO] {
        // We can safely return CountryDTO array since it's now Sendable
        return try await networkClient.request(APIEndpoints.allCountries)
    }
    
    public func searchCountry(query: String) async throws -> [CountryDTO] {
        return try await networkClient.request(APIEndpoints.countryByName(query))
    }
}
