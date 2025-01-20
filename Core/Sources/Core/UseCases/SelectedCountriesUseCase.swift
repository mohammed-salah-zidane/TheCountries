//
//  SelectedCountriesUseCase.swift
//  Core
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// MARK: - Selected Countries Use Case Protocol
public protocol SelectedCountriesUseCaseProtocol: Sendable {
    /// Fetches selected countries from local storage
    /// - Returns: Array of selected Country domain models
    /// - Throws: CoreError if the operation fails
    func fetchSelectedCountries() async throws -> [Country]
    
    /// Saves selected countries to local storage
    /// - Parameter countries: Array of Country domain models to store
    /// - Throws: CoreError.storageError if the operation fails
    func saveSelectedCountries(_ countries: [Country]) async throws
    
    /// Clears all selected countries from local storage
    /// - Throws: CoreError.storageError if the operation fails
    func clearSelectedCountries() async throws
}

// MARK: - Selected Countries Use Case Implementation
public final class SelectedCountriesUseCase: SelectedCountriesUseCaseProtocol {
    // MARK: - Properties
    private let repository: CountryRepositoryProtocol
    
    // MARK: - Initialization
    public init(repository: CountryRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    public func fetchSelectedCountries() async throws -> [Country] {
        return try await repository.fetchSelectedCountries()
    }
    
    public func saveSelectedCountries(_ countries: [Country]) async throws {
        try await repository.saveSelectedCountries(countries)
    }
    
    public func clearSelectedCountries() async throws {
        try await repository.clearSelectedCountries()
    }
}

