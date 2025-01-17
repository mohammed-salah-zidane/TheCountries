//
//  CountryDataSource.swift
//  Data
//
//  Created by Mohamed Salah on 17/01/2025.
//

import Foundation

// Original imports remain the same
import Foundation

// Make protocols public
public protocol CountryDataSource {
    func fetch() async throws -> [CountryDTO]
}

public protocol RemoteCountryDataSource: CountryDataSource {}

public protocol LocalCountryDataSource: CountryDataSource {
    func save(_ items: [CountryDTO]) async throws
    func clear() async throws
    func exists() async -> Bool
}
