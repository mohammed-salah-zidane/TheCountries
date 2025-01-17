//
//  CountryRepository.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation
import Core

// MARK: - Repository Implementation
public class CountryRepository: CountryRepositoryProtocol {
    private let remoteDataSource: any RemoteCountryDataSource
    private let localDataSource: any LocalCountryDataSource
    
    public init(
        remoteDataSource: any RemoteCountryDataSource = RemoteCountryDataSourceImpl(),
        localDataSource: any LocalCountryDataSource = LocalCountryDataSourceImpl()
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    public func fetchAllCountries() async throws -> [Country] {
        do {
            // Try remote first
            let countriesDTO = try await fetchFromRemote()
            return try mapToDomain(countriesDTO)
        } catch {
            // On failure, try local
            let countriesDTO = try await fetchFromLocal()
            return try mapToDomain(countriesDTO)
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchFromRemote() async throws -> [CountryDTO] {
        let countriesDTO = try await remoteDataSource.fetch()
        try await localDataSource.save(countriesDTO) // Cache for offline
        return countriesDTO
    }
    
    private func fetchFromLocal() async throws -> [CountryDTO] {
        return try await localDataSource.fetch()
    }
    
    private func mapToDomain(_ dtos: [CountryDTO]) throws -> [Country] {
        do {
            return try dtos.map(CountryMapper.mapToDomain)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
