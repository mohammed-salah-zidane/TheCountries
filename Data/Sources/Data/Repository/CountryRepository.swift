//
//  CountryRepository.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation
import Core

// MARK: - Repository Implementation
public final class CountryRepository: CountryRepositoryProtocol {
    private let remoteDataSource: any RemoteCountryDataSource
    private let localDataSource: any LocalCountryDataSource
    private let cachePolicy: CachePolicyProtocol
    private let defaults: UserDefaults
    private let lastUpdateKey = "countries_last_update_time"
    
    public init(
        remoteDataSource: any RemoteCountryDataSource = RemoteCountryDataSourceImpl(),
        localDataSource: any LocalCountryDataSource = LocalCountryDataSourceImpl(),
        cachePolicy: CachePolicyProtocol = DefaultCachePolicy(),
        defaults: UserDefaults = .standard
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.cachePolicy = cachePolicy
        self.defaults = defaults
    }
    
    public func fetchAllCountries(policy: DataSourcePolicy = .default) async throws -> [Country] {
        switch policy {
        case .remoteOnly:
            return try await fetchRemoteCountries()
        case .localOnly:
            return try await fetchLocalCountries()
        case .remoteWithLocalFallback:
            return try await fetchRemoteWithFallback()
        case .localWithRemoteRefresh:
            return try await fetchLocalWithRefresh()
        }
    }
    
    public func updateLocalStorage(with countries: [Country]) async throws {
        do {
            let dtos = try countries.map { try mapToDTO(from: $0) }
            try await localDataSource.save(dtos)
            defaults.set(Date(), forKey: lastUpdateKey)
        } catch {
            throw CoreError.storageError(error.localizedDescription)
        }
    }
    
    public func clearLocalStorage() async throws {
        do {
            try await localDataSource.clear()
            defaults.removeObject(forKey: lastUpdateKey)
        } catch {
            throw CoreError.storageError(error.localizedDescription)
        }
    }
    
    public func hasValidLocalData() async -> Bool {
        guard let lastUpdate = defaults.object(forKey: lastUpdateKey) as? Date,
              cachePolicy.isValid(lastUpdateTime: lastUpdate),
              await localDataSource.exists() else {
            return false
        }
        return true
    }
    
    // MARK: - Private Methods
    
    private func fetchRemoteCountries() async throws -> [Country] {
        do {
            let dtos = try await remoteDataSource.fetch()
            try await localDataSource.save(dtos)
            defaults.set(Date(), forKey: lastUpdateKey)
            return try dtos.map { try mapToDomain(from: $0) }
        } catch {
            throw transformError(error)
        }
    }
    
    private func fetchLocalCountries() async throws -> [Country] {
        do {
            let dtos = try await localDataSource.fetch()
            return try dtos.map { try mapToDomain(from: $0) }
        } catch {
            throw transformError(error)
        }
    }
    
    private func fetchRemoteWithFallback() async throws -> [Country] {
        do {
            return try await fetchRemoteCountries()
        } catch {
            return try await fetchLocalCountries()
        }
    }
    
    private func fetchLocalWithRefresh() async throws -> [Country] {
        if await hasValidLocalData() {
            return try await fetchLocalCountries()
        }
        return try await fetchRemoteWithFallback()
    }
    
    private func transformError(_ error: Error) -> CoreError {
        switch error {
        case let networkError as NetworkError:
            return .networkError(networkError.localizedDescription)
        case let coreError as CoreError:
            return coreError
        default:
            return .repositoryError(error.localizedDescription)
        }
    }
    
    // MARK: - Mapping Methods
    
    private func mapToDomain(from dto: CountryDTO) throws -> Country {
        try CountryMapper.mapToDomain(dto: dto)
    }
    
    private func mapToDTO(from country: Country) throws -> CountryDTO {
        try CountryMapper.mapToDTO(country: country)
    }
}
