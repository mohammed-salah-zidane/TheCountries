//
//  FetchCountriesUseCase.swift
//  Core
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// MARK: - Fetch Countries Use Case Protocol
public protocol FetchCountriesUseCaseProtocol {
    /// Executes the use case to fetch all countries
    /// - Parameter policy: Optional data source policy (defaults to .default)
    /// - Returns: Array of Country domain models
    /// - Throws: CoreError if the operation fails
    func execute(policy: DataSourcePolicy?) async throws -> [Country]
}

// MARK: - Fetch Countries Use Case Implementation
public final class FetchCountriesUseCase: FetchCountriesUseCaseProtocol {
    // MARK: - Properties
    
    private let repository: CountryRepositoryProtocol
    private let cachePolicy: CachePolicyProtocol
    
    // MARK: - Initialization
    
    /// Initializes the use case with a repository and cache policy
    /// - Parameters:
    ///   - repository: The repository conforming to CountryRepositoryProtocol
    ///   - cachePolicy: The cache policy for determining data freshness
    public init(
        repository: CountryRepositoryProtocol,
        cachePolicy: CachePolicyProtocol = DefaultCachePolicy()
    ) {
        self.repository = repository
        self.cachePolicy = cachePolicy
    }
    
    // MARK: - Public Methods
    
    public func execute(policy: DataSourcePolicy? = nil) async throws -> [Country] {
        do {
            let effectivePolicy = await determineEffectivePolicy()
            return try await repository.fetchAllCountries(policy: policy ?? effectivePolicy)
        } catch {
            throw transformError(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func determineEffectivePolicy() async -> DataSourcePolicy {
        if await repository.hasValidLocalData() {
            return .localWithRemoteRefresh
        }
        return .remoteWithLocalFallback
    }
    
    private func transformError(_ error: Error) -> CoreError {
        if let coreError = error as? CoreError {
            return coreError
        }
        return .repositoryError(error.localizedDescription)
    }
}
