import Foundation
@testable import Data

class MockRemoteDataSource: RemoteCountryDataSource {
    var mockResult: Result<[CountryDTO], Error> = .success([])
    
    func fetch() async throws -> [CountryDTO] {
        try mockResult.get()
    }
}

class MockLocalDataSource: LocalCountryDataSource {
    var mockResult: Result<[CountryDTO], Error> = .success([])
    var savedItems: [CountryDTO] = []
    var clearCalled = false
    var existsCalled = false
    var shouldExist = false
    
    func fetch() async throws -> [CountryDTO] {
        try mockResult.get()
    }
    
    func save(_ items: [CountryDTO]) async throws {
        savedItems = items
    }
    
    func clear() async throws {
        clearCalled = true
    }
    
    func exists() async -> Bool {
        existsCalled = true
        return shouldExist
    }
}
