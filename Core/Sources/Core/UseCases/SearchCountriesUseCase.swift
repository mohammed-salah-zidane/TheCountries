//
//  SearchCountriesUseCase.swift
//  Core
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// MARK: - Search Countries Use Case Protocol
public protocol SearchCountriesUseCaseProtocol {
    /// Searches countries based on a query string
    /// - Parameters:
    ///   - query: The search query
    ///   - countries: The list of countries to search in
    /// - Returns: Filtered list of countries
    func execute(query: String, in countries: [Country]) -> [Country]
    
    /// Sorts countries based on specified criteria
    /// - Parameters:
    ///   - countries: The list of countries to sort
    ///   - criteria: The sorting criteria to use
    /// - Returns: Sorted list of countries
    func sort(_ countries: [Country], by criteria: Country.SortCriteria) -> [Country]
}

// MARK: - Search Countries Use Case Implementation
public final class SearchCountriesUseCase: SearchCountriesUseCaseProtocol {
    public init() {}
    
    public func execute(query: String, in countries: [Country]) -> [Country] {
        guard !query.isEmpty else { return countries }
        return countries.filter { $0.matches(query: query) }
    }
    
    public func sort(_ countries: [Country], by criteria: Country.SortCriteria) -> [Country] {
        return countries.sorted(by: Country.comparator(for: criteria))
    }
}

