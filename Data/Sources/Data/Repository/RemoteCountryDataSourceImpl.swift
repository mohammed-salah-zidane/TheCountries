//
//  RemoteCountryDataSourceImpl.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// MARK: - Remote Data Source Implementation
public final class RemoteCountryDataSourceImpl: RemoteCountryDataSource {
    private let networkClient: NetworkClientProtocol
    
    public init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    public func fetch() async throws -> [CountryDTO] {
        return try await networkClient.request(APIEndpoints.allCountries)
    }
}
