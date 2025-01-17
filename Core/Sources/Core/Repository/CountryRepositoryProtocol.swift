//
//  CountryRepositoryProtocol.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// MARK: - Repository Protocol
public protocol CountryRepositoryProtocol {
    /// Fetches all countries from either remote or local source
    /// - Returns: Array of Country domain models
    /// - Throws: Error if both remote and local fetches fail
    func fetchAllCountries() async throws -> [Country]
}
